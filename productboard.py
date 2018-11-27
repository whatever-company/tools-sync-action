#!/usr/bin/env python

import re
from uuid import uuid4

import click
import gitlab
import requests
from werkzeug import cached_property

PRODUCTBOARD_URL = 'https://elium.productboard.com'
PRODUCTBOARD_FEATURE_URL = f'{PRODUCTBOARD_URL}/feature-board/97842-backlog/features'
GITLAB_URL = 'https://gitlab.com'
GITLAB_GROUP = 'elium/product'

ZENDESK_TICKET_RE = re.compile("ZD-([0-9]+)")
ZENDESK_API_ENDPOINT = "https://knowledgeplaza.zendesk.com/api/v2/tickets/update_many.json"
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

ZENDESK_STATUS_FROM_PB = {
	'Staging': 'Staging',
	'Released in Prod': 'Production',
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

		response = requests.put(ZENDESK_API_ENDPOINT, params=querystring, json=payload, auth=(self.username, self.password))

		return response

	def get_tickets_from_str(self, text):
		return ZENDESK_TICKET_RE.findall(text)


@click.group()
def cli():
	pass


@cli.group('gitlab')
def group_gitlab():
	pass


@group_gitlab.command('sync')
@click.option('--username')
@click.option('--password')
@click.option('--token')
@click.option('--release')
def gitlab_sync(username, password, token, release):
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
		labels = []

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


@cli.group('productboard')
def group_productboard():
	pass


@group_productboard.command('sync')
@click.option('--username')
@click.option('--password')
@click.option('--status')
@click.argument('gitlab-issues', nargs=-1)
def productboard_sync(username, password, gitlab_issues, status):
	""" Update productboard status based on gitlab issues"""

	pb = Productboard(username, password)
	pb.login()

	if not gitlab_issues:
		raise click.UsageError('No issue found.')

	new_status_id, new_status_label = pb.state_label(name=status)

	if not new_status_id:
		raise click.UsageError('Could not find matching status')

	for issue_id in gitlab_issues:
		click.echo(f"Processing: {issue_id}")
		issue_url = f'{GITLAB_URL}/{issue_id}'
		feature = pb.feature_by_gitlab_url(issue_url)
		if feature:
			click.echo(f'feature {feature["id"]} found: {feature["name"]}')
			old_status_id = feature['state_id']
			_, old_status_label = pb.state_label(state_id=old_status_id)

			if PRODUCTBOARD_STATUSES.index(old_status_label) < PRODUCTBOARD_STATUSES.index(new_status_label):
				pb.update_feature_status(feature, new_status_id)
				click.echo(f'Status updated')
			else:
				click.echo(f'Skip issue, status is already more advanced')
		else:
			click.echo(f'feature not found {issue_id}')


@cli.group('zendesk')
def group_zendesk():
	pass


@group_zendesk.command('sync')
@click.option('--username')
@click.option('--password')
@click.option('--status')
@click.option('--token')
@click.argument('gitlab-issues', nargs=-1)
def zendesk_sync(username, password, gitlab_issues, status, token):
	""" Update Zendesk status based on gitlab issues"""

	zd = Zendesk(username, password)

	gl = EliumGitlab(GITLAB_URL, private_token=token)

	if not gitlab_issues:
		raise click.UsageError('No issue found.')

	zd_ticket_ids = []
	for issue_id in gitlab_issues:
		gitlab_issue = gl.get_issue_from_url(issue_id)
		# probably never more than 1
		zd_ticket_ids = zd_ticket_ids + zd.get_tickets_from_str(gitlab_issue.title)

	# Update zendesk only for given stages
	if not zd_ticket_ids:
		click.echo('No zendesk issue to sync')
	else:
		if status in ZENDESK_STATUS_FROM_PB:
			status = {
				"ticket": {
					"additional_tags": f"deployed in {ZENDESK_STATUS_FROM_PB[status]}",
					"comment": {
						"body": f"A fix was released in {ZENDESK_STATUS_FROM_PB[status]}",
						"public": False
					},
					"assignee_id": ZENDESK_CSTEAM_ID,
					"status": "open",
				}
			}
			click.echo(f'Update status for {zd_ticket_ids}')
			response = zd.update_tickets(zd_ticket_ids, status)
			click.echo(f'ZD update: {response.text}')


if __name__ == '__main__':
	cli()
