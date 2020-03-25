#!/usr/bin/env python

import json
import re
from uuid import uuid4

import click
import requests
import semver
from dotenv import load_dotenv
from github import Github, GithubException
from werkzeug.utils import cached_property

# Load dot file as ENV
load_dotenv()

PRODUCTBOARD_URL = 'https://elium.productboard.com'
PRODUCTBOARD_FEATURE_URL = f'{PRODUCTBOARD_URL}/feature-board/97842-backlog/features'
ISSUE_RE = re.compile("#([0-9]+)")

GITHUB_ORGANISATION = 'whatever-company'
ZENDESK_TICKET_RE = re.compile("ZD-([0-9]+)")
ZENDESK_URL = "https://knowledgeplaza.zendesk.com"
ZENDESK_CS_TEAM_ID = 22392423
ZENDESK_BUGS_TEAM_ID = 360003060151

PRODUCTBOARD_STATUSES = [
	'New idea',
	'Need Product Work',
	'Need Refinement',
	'Blocked',
	'Ready',
	'In progress',
	'Done',
	'Staging',
	'Released in Prod',
	'Archived',
]

PRODUCTBOARD_TO_ENV = {
	'Staging': 'Staging',
	'Released in Prod': 'Production',
	'Done': 'Development',
}
PROJECT_TO_EMOJI = {
	'elium-web': '⚛️',
	'elium-backend': '⚙️',
	# 'elium-mobile': '📞',
	'website': '🌍',
	'learn': '📄',
	# 'infra/...': '🏗',
}

WEIGHTS = {
	'XS': 0,
	'S': 1,
	'M': 3,
	'L': 8,
	'XL': 13,
	'XXL': 20,
}


def get_issues_from_commits(project, commits):
	issues_ids = set()
	for commit in commits:
		match = ISSUE_RE.findall(commit.commit.message)
		issues_ids = issues_ids.union(set(match))
	issues = []
	for i in issues_ids:
		try:
			issues.append(project.get_issue(int(i)))
		except GithubException:
			pass
	return issues


class Productboard:
	def __init__(self, username, password):
		self.username = username
		self.password = password
		self.session = requests.Session()

	def login(self):
		self.csrf_token = re.search(r'window.csrfToken = \'(.*)\'', self.session.get(PRODUCTBOARD_URL).text).group(1)
		self.session.post(
			f'{PRODUCTBOARD_URL}/users/sign_in', headers={
				'X-CSRF-Token': self.csrf_token,
			}, data={
				'user[email]': self.username,
				'user[password]': self.password,
			}
		)
		self.fetch_csrf()

	def fetch_csrf(self):
		self.csrf_token = re.search(r'window.csrfToken = \'(.*)\'', self.session.get(PRODUCTBOARD_URL).text).group(1)

	@cached_property
	def all(self):
		return self.session.get(f'{PRODUCTBOARD_URL}/api/all.json').json()

	def get_release(self, name=None):
		""" Fetch the release by name of the current in progress """
		for release in self.all['releases']:
			if (name and release['name'].lower() == name.lower()) or (not name and release['state'].lower() == 'in-progress'):
				return release

	def features_by_release(self, release):
		feature_ids = [i['feature_id'] for i in self.all['release_assignments'] if i['release_id'] == release['id']]

		for feature in self.all['features']:
			if feature['id'] in feature_ids:
				yield feature

	def feature_by_gitlab_url(self, url):
		for feature in self.all['features']:
			col_value = self.get_gitlab_column_value(feature)
			if col_value and col_value.get('text_value') == url:
				return feature

	def state_label(self, name=None, state_id=None):
		""" Get the Id, name behind feature state label or id """
		for column in self.all['columns']:
			if column['column_type'] == 'feature_state':
				if (name and column['name'].lower() == name.lower()) or (state_id and state_id == column['columnable_id']):
					return column['columnable_id'], column['name']

	@cached_property
	def gitlab_column(self):
		for column in self.all['columns']:
			if column['name'] == 'Gitlab':
				return column['id']

	@cached_property
	def estimate_column(self):
		for column in self.all['columns']:
			if column['name'] == 'T-shirt':
				return column['id']

	def estimate_label(self, estimate_id):
		""" Get the Id, name behind feature state label or id """
		for item in self.all['list_column_items']:
			if item['id'] == estimate_id:
				return item['label']

	def get_gitlab_column_value(self, feature):
		for col_value in self.all['column_values']:
			if col_value['column_id'] == self.gitlab_column and col_value['feature_id'] == feature['id']:
				return col_value

	def get_estimate_column_value(self, feature):
		for col_value in self.all['column_values']:
			if col_value['column_id'] == self.estimate_column and col_value['feature_id'] == feature['id']:
				# value is a label in list, should be resolved
				return self.estimate_label(col_value.get('value'))

	def update_feature_gitlab(self, feature, gitlab_url):
		col_value = self.get_gitlab_column_value(feature)
		if col_value:
			response = self.session.put(
				f"{PRODUCTBOARD_URL}/api/column_values/{col_value['id']}", headers={
					'X-CSRF-Token': self.csrf_token,
					'Content-Type': 'application/json',
				}, json={"column_value": {
					"text_value": gitlab_url
				}}
			)
			response.raise_for_status()
		else:
			response = self.session.post(
				f"{PRODUCTBOARD_URL}/api/column_values",
				headers={
					'X-CSRF-Token': self.csrf_token,
					'Content-Type': 'application/json',
				},
				json={
					"column_value": {
						"text_value": gitlab_url,
						"feature_id": feature['id'],
						"column_id": self.gitlab_column,
						"id": str(uuid4()),
					},
				}
			)
			response.raise_for_status()

	def update_feature_status(self, feature, status_id):
		""" Update feature status with given status ID """
		response = self.session.put(
			f"{PRODUCTBOARD_URL}/api/features/{feature['id']}", headers={
				'X-CSRF-Token': self.csrf_token,
				'Content-Type': 'application/json',
			}, json={"feature": {
				"state_id": status_id
			}}
		)
		response.raise_for_status()


class Zendesk:
	def __init__(self, username, password):
		self.username = username
		self.password = password

	def update_tickets(self, ids, payload):
		# https://developer.zendesk.com/rest_api/docs/support/tickets#request-body

		querystring = {"ids": ','.join(ids)}

		response = requests.put(f'{ZENDESK_URL}/api/v2/tickets/update_many.json', params=querystring, json=payload, auth=(self.username, self.password))

		return response

	def get_tickets(self, ids):
		querystring = {"ids": ','.join(ids)}

		response = requests.get(f'{ZENDESK_URL}/api/v2/tickets/show_many.json', params=querystring, auth=(self.username, self.password))

		return response.json()

	def get_ticket_ids_from_str(self, text):
		return ZENDESK_TICKET_RE.findall(text)


def get_issues_from_gh_list_or_repo(github_client, project, commits, issues_names):
	""" Fetch issues using Github's commits messages or
	the provided issues_names list using the format : whatever-company/elium-backend/issues/352

	return a list of github issues object
	"""

	issues_objects = []
	# Find Issues using Repo
	if commits:
		issues_from_commits = get_issues_from_commits(project, commits)
		issues_objects = issues_objects + issues_from_commits

	if issues_names:
		# Find Issues usings CLI param
		for issue_id in issues_names:
			issues_objects.append(github_client.get_issue_from_url(issue_id))

	return issues_objects


@click.group()
def cli():
	pass


@cli.group('from_productboard')
@click.option('--dry-run', is_flag=True)
@click.pass_context
def from_productboard(ctx, dry_run):
	ctx.ensure_object(dict)
	ctx.obj['dry_run'] = dry_run


@from_productboard.command('to_github')
@click.option('--username', envvar="PB_USERNAME")
@click.option('--password', envvar="PB_PASSWORD")
@click.option('--token', envvar="GH_TOKEN")
@click.option('--release', envvar="RELEASE")
@click.pass_context
def to_github(ctx, username, password, token, release):
	""" Create / Update Github issues based on given Productboard Release """
	pb = Productboard(username, password)
	gh = Github(token)

	pb.login()

	productboard_release = pb.get_release(release)
	if not productboard_release:
		raise click.UsageError('No such release')
	click.echo(f'Found release {productboard_release}')

	github_projects = {f'{GITHUB_ORGANISATION}/{project}': gh.get_repo(f'{GITHUB_ORGANISATION}/{project}') for project in PROJECT_TO_EMOJI}

	for feature in pb.features_by_release(productboard_release):
		click.echo(f"Processing: {feature['name']}")

		project = f'{GITHUB_ORGANISATION}/elium-web'
		# Map Emoji to Project
		for project_url, emoji in PROJECT_TO_EMOJI.items():
			if emoji in feature['name']:
				project = f'{GITHUB_ORGANISATION}/{project_url}'
				break
		labels = []

		pb_github_link = pb.get_gitlab_column_value(feature)

		if pb_github_link and pb_github_link.get('text_value'):
			# Issue exists, let's update it
			issue_url = pb_github_link['text_value']
			click.echo(f"... feature already linked: {issue_url}")
			if "gitlab.com" in issue_url:
				click.secho('Skip Gitlab Issue sync', color="orange")
				continue
			issue_id = issue_url.split('/')[-1]

			# Find project based on url instead of emoji
			sub_project = issue_url.split('/')[-3]
			project = f'{GITHUB_ORGANISATION}/{sub_project}'

			github_project = github_projects[project]
			issue = github_project.get_issue(issue_id)
			title = feature['name']
			description = f"{PRODUCTBOARD_FEATURE_URL}/{feature['id']}/detail\n\n{feature['description']}"

			try:
				if not ctx.obj.get('dry_run', False):
					issue.edit(title=title, body=description)
				click.echo(f'... issue update -> {issue.html_url}')
			except GithubException as e:
				click.secho(f'Error updating issue : {e}', err=True, fg='red')

		else:
			click.echo(f'... creating issue in {project}')
			github_project = github_projects[project]

			if not ctx.obj.get('dry_run', False):
				issue = github_projects.create_issue(
					title=feature['name'],
					body=f"{PRODUCTBOARD_FEATURE_URL}/{feature['id']}/detail\n\n{feature['description']}",
				)
				pb.update_feature_gitlab(feature, issue.html_url)
				click.echo(f'... -> {issue.html_url}')
			else:
				click.echo(f'Dry run issue created')


@cli.group('from_github', chain=True)
@click.option('--token', envvar="GH_TOKEN")
@click.option('--project', envvar="GH_PROJECT")
@click.option('--from-ref', envvar="FROM_REF")
@click.option('--to-ref', envvar="TO_REF")
@click.option('--status', envvar="STATUS")
@click.option('--linear', envvar="LINEAR_RELEASE", help="Staging is always further or eq than prod")
@click.option('--dry-run', is_flag=True)
@click.pass_context
def group_from_github(ctx, token, project, from_ref, to_ref, status, linear, dry_run):
	click.secho("Start setup", color="green", underline=True)
	click.echo(f'received from_ref={from_ref} to_ref={to_ref} status={status}')

	ctx.ensure_object(dict)
	# pass down some var
	ctx.obj['dry_run'] = dry_run

	ctx.obj['gh_client'] = Github(token)
	ctx.obj['project'] = ctx.obj['gh_client'].get_repo(project)

	ctx.obj['to_ref'] = to_ref
	if not from_ref and to_ref.startswith("v"):
		click.echo(f"Process preceding version of {to_ref}")
		current_version = semver.parse_version_info(to_ref[1:])
		tags = ctx.obj['project'].get_tags()
		previous_version = semver.parse_version_info('0.0.0')
		for git_tag in tags:
			try:
				tag_version = semver.parse_version_info(git_tag.name[1:])
			except ValueError:
				continue
			if not linear:
				if (current_version.prerelease and not tag_version.prerelease) or (not current_version.prerelease and tag_version.prerelease):
					# only tag pre release toghether or release toghether
					continue
			if tag_version < current_version and tag_version > previous_version:
				previous_version = tag_version
		from_ref = f"v{previous_version}"
		click.echo(f"Found from {from_ref}")

	ctx.obj['from_ref'] = from_ref
	ctx.obj['status'] = status

	if status in PRODUCTBOARD_TO_ENV:
		ctx.obj['environment'] = PRODUCTBOARD_TO_ENV[status]
	else:
		ctx.obj['environment'] = 'Development'

	if from_ref and to_ref and project:
		click.secho(f"From {from_ref} to {to_ref}", color="green")
		compare = ctx.obj['project'].compare(from_ref, to_ref)
		ctx.obj['diff_link'] = compare.diff_url
		ctx.obj['commits'] = compare.commits or []
	else:
		ctx.obj['commits'] = []
		ctx.obj['diff_link'] = None

	click.echo(f"Fetching Issues")

	issues_names = []
	ctx.obj['issues'] = get_issues_from_gh_list_or_repo(ctx.obj['gh_client'], ctx.obj['project'], ctx.obj['commits'], issues_names=issues_names)

	click.echo(f"{len(ctx.obj['issues'])} GitHub Issues found")


@group_from_github.command('to_zendesk')
@click.option('--zd-username', envvar="ZD_USERNAME")
@click.option('--zd-password', envvar="ZD_PASSWORD")
@click.pass_context
def to_zendesk(ctx, zd_username, zd_password):
	click.secho('Sync to Zendesk', color="green", underline=True)
	environment = ctx.obj['environment']

	if environment not in ('Production', 'Staging', 'Development'):
		click.echo(f"Not syncing status {environment}")
		return

	zd = Zendesk(zd_username, zd_password)

	zd_ticket_ids = set()

	# Find Zendesk issues in commit messages
	for commit in ctx.obj['commits']:
		click.echo(f"Processing: {commit.sha}")
		zd_id_found = zd.get_ticket_ids_from_str(commit.commit.message)
		zd_ticket_ids = zd_ticket_ids.union(zd_id_found)
		if zd_id_found:
			click.echo(f'Found {zd_id_found}')

	# Find Zendesk issues ids
	for issue in ctx.obj['issues']:
		# probably never more than 1 but let's be safe
		click.echo(f'Processing: {issue.title}')
		zd_id_found = zd.get_ticket_ids_from_str(issue.title)
		zd_ticket_ids = zd_ticket_ids.union(zd_id_found)
		if zd_id_found:
			click.echo(f'Found {zd_id_found}')

	# Update zendesk only for given stages
	if not zd_ticket_ids:
		click.echo('No zendesk issue to sync')
		return

	click.echo(f'Fetching tickets: {zd_ticket_ids}')

	tickets = zd.get_tickets(zd_ticket_ids)
	for ticket in tickets['tickets']:
		payload = {
			"ticket": {
				"additional_tags": f"deployed-in-{environment}",
				"comment": {
					"body": f"A fix was released in {environment}",
					"public": False
				},
			}
		}

		click.echo(f'got {ticket["id"]} in status : {ticket["status"]}')

		# Avoid resync what's already synced
		if 'deployed-in-production' in ticket['tags']:
			click.echo(f'skip {ticket["id"]}, already in production')
			continue
		if 'deployed-in-staging' in ticket['tags'] and environment != 'Production':
			click.echo(f'skip {ticket["id"]}, already marked as synced in staging')
			continue
		if 'deployed-in-development' in ticket['tags'] and environment not in ('Production', 'Staging'):
			click.echo(f'skip {ticket["id"]}, already marked as synced in development')
			continue

		if environment == 'Production' and ticket['status'] not in ('closed', 'solved'):
			payload['ticket']['status'] = 'open'

		click.echo(f'syncing ticket {ticket["id"]}')
		if not ctx.obj.get('dry_run', False):
			response = zd.update_tickets([str(ticket["id"])], payload)
			click.echo(f'ZD update: {response.text}')


@group_from_github.command('to_productboard')
@click.option('--pb-username', envvar="PB_USERNAME")
@click.option('--pb-password', envvar="PB_PASSWORD")
@click.pass_context
def to_productboard(ctx, pb_username, pb_password):
	click.secho('Sync to Productboard', color="green", underline=True)

	pb = Productboard(pb_username, pb_password)
	# print("ici", pb.all)
	pb.login()
	if not ctx.obj['issues']:
		click.echo('Could not find issues Tag')
		return
	new_status_id, new_status_label = pb.state_label(name=ctx.obj['status'])

	for issue in ctx.obj['issues']:
		click.echo(f"Processing: {issue.id} {issue.html_url}")
		feature = pb.feature_by_gitlab_url(issue.html_url)
		if feature:
			click.echo(f'feature {feature["id"]} found: {feature["name"]}')
			old_status_id = feature['state_id']
			_, old_status_label = pb.state_label(state_id=old_status_id)

			if PRODUCTBOARD_STATUSES.index(old_status_label) < PRODUCTBOARD_STATUSES.index(new_status_label):
				if not ctx.obj.get('dry_run', False):
					pb.update_feature_status(feature, new_status_id)
				click.echo(f'Status updated')
			else:
				click.echo(f'Skip issue, status is already more advanced')
		else:
			click.echo(f'feature not found {issue.id}')


@group_from_github.command('to_slack')
@click.option('--slack-url', envvar="SLACK_URL")
@click.pass_context
def to_slack(ctx, slack_url):
	click.secho("Announcing release on slack", color="green", underline=True)
	environment = ctx.obj['environment']
	project_name = ctx.obj['project'].name
	project_icon = PROJECT_TO_EMOJI[project_name] if project_name in PROJECT_TO_EMOJI else ''
	if environment not in ('Production', 'Staging'):
		click.echo('Announcing only prod/staging release')
		return

	diff_link = ctx.obj['diff_link']
	from_ref = ctx.obj['from_ref']
	to_ref = ctx.obj['to_ref']
	commits = ctx.obj['commits']
	commits_titles = []
	for commit in commits:
		commits_titles.append(f"<{commit.html_url}|{commit.sha[0:7]}> {commit.commit.message}")
	commits_str = '\n'.join(commits_titles)
	payload = {
		"attachments": [{
			"title": f"Deployed on {project_icon} {project_name} - {environment} : {to_ref} \n ({len(commits)} commits)",
			"title_link": diff_link,
			"color": "#36a64f" if environment == 'Production' else "#a5a5a5",
			"text": f"\n\n\n\n\n{commits_str}",
			"footer": f"diff: <{diff_link}|{from_ref}...{to_ref}>",
			"fields": [
				{
					"title": "Environment",
					"value": environment,
					"short": True,
				},
				{
					"title": "Project",
					"value": project_name,
					"short": True,
				},
				{
					"title": "Deployed Ref",
					"value": to_ref,
					"short": True,
				},
			]
		}]
	}

	if not ctx.obj.get('dry_run', False):
		result = requests.post(slack_url, json=payload)
		click.echo("->")
		click.echo(result.text)
	else:
		click.echo(json.dumps(payload))


@group_from_github.command('to_datadog')
@click.option('--datadog-key', envvar="DD_KEY")
@click.pass_context
def to_datadog(ctx, datadog_key):
	click.secho("Announcing release on datadog", color="green", underline=True)

	diff_link = ctx.obj['diff_link']
	to_ref = ctx.obj['to_ref']
	commits = ctx.obj['commits']
	environment = ctx.obj['environment']
	payload = {
		"title": f"Just deployed {to_ref} on {environment}",
		"text": f" [{len(commits)} commits]({diff_link})",
		"priority": "normal",
		"tags": [f"deployment:{environment}"],
		"alert_type": "info",
		"source": "Git",
	}

	if not ctx.obj.get('dry_run', False):
		result = requests.post(f"https://app.datadoghq.com/api/v1/events?api_key={datadog_key}", json=payload)
		click.echo("->")
		click.echo(result.text)


@group_from_github.command('to_test')
@click.pass_context
def to_test(ctx):
	click.secho('Sync to TEST', color="green", underline=True)
	environment = ctx.obj['environment']
	click.echo(f"syncing status {environment}")
	for issue in ctx.obj['issues']:
		click.echo(f'Found {issue.id}')


if __name__ == '__main__':
	cli()
