#!/usr/bin/env python

import re
from urllib.parse import quote_plus
from uuid import uuid4
import json

import click
import gitlab
import requests
from dotenv import load_dotenv
from werkzeug.utils import cached_property

# Load dot file as ENV
load_dotenv()

PRODUCTBOARD_URL = 'https://elium.productboard.com'
PRODUCTBOARD_FEATURE_URL = f'{PRODUCTBOARD_URL}/feature-board/97842-backlog/features'
GITLAB_URL = 'https://gitlab.com'
GITLAB_GROUP = 'elium/product'

GITLAB_ISSUE_RE = re.compile("#([0-9]+)")

ZENDESK_TICKET_RE = re.compile("ZD-([0-9]+)")
ZENDESK_URL = "https://knowledgeplaza.zendesk.com"
ZENDESK_CSTEAM_ID = 360003060151

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
	'elium-mobile': '📞',
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


class EliumGitlab(gitlab.Gitlab):
	def get_issue_from_url(self, url):
		""" Fetch gitlab issue using url like: elium/product/elium-backend/issues/352 """
		url_parts = url.split('/')

		gl_group_name = '/'.join(url_parts[:3])
		gitlab_project = self.projects.get(gl_group_name)
		issue = gitlab_project.issues.get(url_parts[-1])

		return issue

	def get_diff_link(self, project, from_ref, to_ref):
		return f"{GITLAB_URL}/{project}/compare/{quote_plus(from_ref)}...{quote_plus(to_ref)}"

	def get_issues_from_commits(self, project, commits):
		gl_issues_ids = set()
		for commit in commits:
			match = GITLAB_ISSUE_RE.findall(commit['message'])
			gl_issues_ids = gl_issues_ids.union(set(match))
		issues = [] 
		for i in gl_issues_ids:
			try:
				issues.append(project.issues.get(i))
			except gitlab.exceptions.GitlabGetError:
				pass
		return issues


class Productboard:
	def __init__(self, username, password):
		self.username = username
		self.password = password
		self.session = requests.Session()

	def login(self):
		self.csrf_token = re.search(r'\<meta name=\"csrf-token\" content=\"(.*)\"', self.session.get(PRODUCTBOARD_URL).text).group(1)
		self.session.post(
			f'{PRODUCTBOARD_URL}/users/sign_in', headers={
				'X-CSRF-Token': self.csrf_token,
			}, data={
				'user[email]': self.username,
				'user[password]': self.password,
			}
		).raise_for_status()
		self.csrf_token = re.search(r'window.csrfToken = \'(.*)\'', self.session.get(PRODUCTBOARD_URL).text).group(1)

	@cached_property
	def all(self):
		return self.session.get(f'{PRODUCTBOARD_URL}/api/all.json').json()

	def get_release(self, name):
		for release in self.all['releases']:
			if (name and release['name'].lower() == name.lower()) or (not name and release['state'].lower() == 'in-progress'):
				return release

	def features_by_release(self, release):
		for feature in self.all['features']:
			if feature['release_id'] == release['id']:
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


def get_commits(project, from_ref, to_ref):
	return project.repository_compare(from_ref, to_ref)['commits']


def get_issues_from_list_or_repo(gitlab_client, project, commits, issues_names):
	""" Fetch issues using Gitlab's commits messages or
	the provided issues_names list using the format : elium/product/elium-backend/issues/352

	return a list of gitlab issues object
	"""

	issues_objects = []
	# Find Issues using Repo
	if commits:
		issues_from_commits = gitlab_client.get_issues_from_commits(project, commits)
		issues_objects = issues_objects + issues_from_commits

	if issues_names:
		# Find Issues usings CLI param
		for issue_id in issues_names:
			issues_objects.append(gitlab_client.get_issue_from_url(issue_id))

	return issues_objects


@click.group()
def cli():
	pass


@cli.group('from_productboard')
def from_productboard():
	pass


@from_productboard.command('to_gitlab')
@click.option('--username', envvar="PB_USERNAME")
@click.option('--password', envvar="PB_PASSWORD")
@click.option('--token', envvar="GL_TOKEN")
@click.option('--release', envvar="RELEASE")
def to_gitlab(username, password, token, release):
	""" Create / Update Gitlab issues based on given Productboard Release """

	pb = Productboard(username, password)
	gl = EliumGitlab(GITLAB_URL, private_token=token)

	pb.login()
	r = pb.get_release(release)
	if not r:
		raise click.UsageError('No such release')

	gitlab_group = gl.groups.get(GITLAB_GROUP)
	try:
		gitlab_milestone = gitlab_group.milestones.create({'title': release})
		click.echo(f'Creating new group milestone in {GITLAB_GROUP}: {gitlab_milestone.title}')
	except gitlab.exceptions.GitlabCreateError:
		gitlab_milestones = gitlab_group.milestones.list(search=release.lower())
		if gitlab_milestones:
			gitlab_milestone = gitlab_milestones[0]
			click.echo(f'Using existing milestone: {gitlab_milestone.title}')
		else:
			raise click.UsageError('Milestone was not found')

	gitlab_projects = {project: gl.projects.get(project) for project in (f'{GITLAB_GROUP}/elium-web', f'{GITLAB_GROUP}/elium-mobile', f'{GITLAB_GROUP}/elium-backend')}

	for feature in pb.features_by_release(r):
		click.echo(f"Processing: {feature['name']}")

		project = f'{GITLAB_GROUP}/elium-web'
		if '📞' in feature['name']:
			project = f'{GITLAB_GROUP}/elium-mobile'
		elif '⚙' in feature['name']:
			project = f'{GITLAB_GROUP}/elium-backend'
		elif '🏗' in feature['name']:
			# No idea how to map infra projects, let's skip them
			continue
		labels = []

		# DEPRECATED
		if '🐛' in feature['name']:
			labels.append('Bug')
		if '💣' in feature['name']:
			labels.append('SLA')
		if '🚧' in feature['name']:
			labels.append('Blocker')


		col_value = pb.get_gitlab_column_value(feature)

		if col_value and col_value.get('text_value'):
			issue_url = col_value['text_value']
			click.echo(f"... feature already linked: {issue_url}")
			issue_id = issue_url.split('/')[-1]

			# Find project based on url instead of emoji
			sub_project = issue_url.split('/')[-3]
			project = f'{GITLAB_GROUP}/{sub_project}'

			gitlab_project = gitlab_projects[project]
			editable_issue = gitlab_project.issues.get(issue_id, lazy=True)
			editable_issue.title = feature['name']
			editable_issue.description = f"{PRODUCTBOARD_FEATURE_URL}/{feature['id']}/detail\n\n{feature['description']}"
			editable_issue.milestone_id = gitlab_milestone.id
			t_shirt = pb.get_estimate_column_value(feature)
			if t_shirt:
				editable_issue.weight = WEIGHTS[t_shirt]

			try:
				editable_issue.save()
				click.echo(f'... issue update -> {editable_issue.web_url}')
			except gitlab.exceptions.GitlabUpdateError as e:
				click.secho(f'Error updating issue : {e}', err=True, fg='red')

		else:
			click.echo(f'... creating issue in {project}')
			gitlab_project = gitlab_projects[project]
			issue_data = {
				'title': feature['name'],
				'description': f"{PRODUCTBOARD_FEATURE_URL}/{feature['id']}/detail\n\n{feature['description']}",
				'milestone_id': gitlab_milestone.id,
				'labels': labels,
			}
			t_shirt = pb.get_estimate_column_value(feature)
			if t_shirt:
				issue_data['weight'] = WEIGHTS[t_shirt]

			issue = gitlab_project.issues.create(issue_data)
			issue.unsubscribe()

			pb.update_feature_gitlab(feature, issue.web_url)
			click.echo(f'... -> {issue.web_url}')


@cli.group('from_gitlab', chain=True)
@click.option('--token', envvar="GL_TOKEN")
@click.option('--project', envvar="GL_PROJECT")
@click.option('--from-ref', envvar="FROM_REF")
@click.option('--to-ref', envvar="TO_REF")
@click.option('--status', envvar="STATUS")
@click.option('--gitlab-issues', envvar="GL_ISSUES")
@click.option('--dry-run', is_flag=True)
@click.pass_context
def group_from_gitlab(ctx, token, project, from_ref, to_ref, status, gitlab_issues, dry_run):
	click.secho("Start setup", color="green", underline=True)

	ctx.ensure_object(dict)
	# pass down some var
	ctx.obj['dry_run'] = dry_run

	ctx.obj['from_ref'] = from_ref
	ctx.obj['to_ref'] = to_ref
	ctx.obj['status'] = status

	if status in PRODUCTBOARD_TO_ENV:
		ctx.obj['environment'] = PRODUCTBOARD_TO_ENV[status]
	else:
		ctx.obj['environment'] = 'Development'

	ctx.obj['gl_client'] = EliumGitlab(GITLAB_URL, private_token=token)
	ctx.obj['project'] = ctx.obj['gl_client'].projects.get(project)

	if from_ref and to_ref and project:
		ctx.obj['diff_link'] = ctx.obj['gl_client'].get_diff_link(project, from_ref, to_ref)
		ctx.obj['commits'] = get_commits(ctx.obj['project'], from_ref, to_ref)
	else:
		ctx.obj['commits'] = None
		ctx.obj['diff_link'] = None

	click.echo(f"Fetching Issues")

	issues_names = []
	if gitlab_issues:
		issues_names = gitlab_issues.split()
	ctx.obj['issues'] = get_issues_from_list_or_repo(ctx.obj['gl_client'], ctx.obj['project'], ctx.obj['commits'], issues_names=issues_names)

	click.echo(f"{len(ctx.obj['issues'])} Gitlab Issues found")


@group_from_gitlab.command('to_zendesk')
@click.option('--zd-username', envvar="ZD_USERNAME")
@click.option('--zd-password', envvar="ZD_PASSWORD")
@click.pass_context
def to_zendesk(ctx, zd_username, zd_password):
	click.secho('Sync to Zendesk', color="green", underline=True)
	environment = ctx.obj['environment']
	if not ctx.obj['issues']:
		click.echo('Could not find issues Tag')
		return

	if environment not in ('Production', 'Staging', 'Development'):
		click.echo(f"Not syncing status {environment}")
		return

	zd = Zendesk(zd_username, zd_password)

	zd_ticket_ids = set()
	# Find Zendesk issues ids
	for gitlab_issue in ctx.obj['issues']:
		# probably never more than 1 but let's be safe
		click.echo(f'Processing: {gitlab_issue.title}')
		zd_id_found = zd.get_ticket_ids_from_str(gitlab_issue.title)
		zd_ticket_ids = zd_ticket_ids.union(zd_id_found)
		if zd_id_found:
			click.echo(f'Found {zd_id_found}')

	# Update zendesk only for given stages
	if not zd_ticket_ids:
		click.echo('No zendesk issue to sync')
		return

	payload = {
		"ticket": {
			"additional_tags": f"deployed-in-{environment}",
			"comment": {
				"body": f"A fix was released in {environment}",
				"public": False
			},
		}
	}

	click.echo(f'Fetching tickets: {zd_ticket_ids}')

	tickets = zd.get_tickets(zd_ticket_ids)

	for ticket in tickets['tickets']:
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

		if environment == 'Production':
			payload['ticket']['status'] = 'open'

		click.echo(f'syncing ticket {ticket["id"]}')
		if not ctx.obj.get('dry_run', False):
			response = zd.update_tickets([str(ticket["id"])], payload)
			click.echo(f'ZD update: {response.text}')


@group_from_gitlab.command('to_productboard')
@click.option('--pb-username', envvar="PB_USERNAME")
@click.option('--pb-password', envvar="PB_PASSWORD")
@click.pass_context
def to_productboard(ctx, pb_username, pb_password):
	click.secho('Sync to Productboard', color="green", underline=True)

	if not ctx.obj['issues']:
		click.echo('Could not find issues Tag')
		return

	pb = Productboard(pb_username, pb_password)
	pb.login()

	new_status_id, new_status_label = pb.state_label(name=ctx.obj['status'])

	for issue in ctx.obj['issues']:
		click.echo(f"Processing: {issue.id} {issue.web_url}")
		feature = pb.feature_by_gitlab_url(issue.web_url)
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


@group_from_gitlab.command('to_slack')
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
		url = f"{ctx.obj['project'].web_url}/commit/{commit['id']}"
		commits_titles.append(f"<{url}|{commit['short_id']}> {commit['title']}")
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


@group_from_gitlab.command('to_datadog')
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
		"tags": [f"deployment:{environment}-{to_ref}"],
		"alert_type": "info",
		"source": "Git",
	}

	if not ctx.obj.get('dry_run', False):
		result = requests.post(f"https://app.datadoghq.com/api/v1/events?api_key={datadog_key}", json=payload)
		click.echo("->")
		click.echo(result.text)


if __name__ == '__main__':
	cli()
