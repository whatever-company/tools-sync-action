#!/usr/bin/env python

import re
import sys
from uuid import uuid4

import requests
import gitlab
import click
from werkzeug import cached_property

PRODUCTBOARD_URL = 'https://elium.productboard.com'
PRODUCTBOARD_FEATURE_URL = f'{PRODUCTBOARD_URL}/feature-board/97842-backlog/features'
GITLAB_URL = 'https://gitlab.com'
GITLAB_GROUP = 'elium/product'

class Productboard:
	def __init__(self, username, password):
		self.username = username
		self.password = password
		self.session = requests.Session()

	def login(self):
		self.csrf_token = re.search(r'\<meta name=\"csrf-token\" content=\"(.*)\"', self.session.get(PRODUCTBOARD_URL).text).group(1)
		self.session.post(
			f'{PRODUCTBOARD_URL}/users/sign_in',
			headers={
				'X-CSRF-Token': self.csrf_token,
			},
			data={
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
			if release['name'].lower() == name.lower():
				return release

	def features_by_release(self, release):
		for feature in self.all['features']:
			if feature['release_id'] == release['id']:
				yield feature

	@cached_property
	def gitlab_column(self):
		for column in self.all['columns']:
			if column['name'] == 'Gitlab':
				return column['id']

	def get_gitlab_column_value(self, feature):
		for col_value in self.all['column_values']:
			if col_value['column_id'] == self.gitlab_column and col_value['feature_id'] == feature['id']:
				return col_value

	def update_feature_gitlab(self, feature, gitlab_url):
		col_value = self.get_gitlab_column_value(feature)
		if col_value:
			response = self.session.put(
				f"{PRODUCTBOARD_URL}/api/column_values/{col_value['id']}",
				headers={
					'X-CSRF-Token': self.csrf_token,
				},
				json={
					"column_value":{
						"text_value":gitlab_url
					}
				}
			)
			response.raise_for_status()
		else:
			response = self.session.post(
				f"{PRODUCTBOARD_URL}/api/column_values",
				headers={
					'X-CSRF-Token': self.csrf_token,
				},
				json={
					"column_value":{
						"text_value":gitlab_url,
						"feature_id":feature['id'],
						"column_id":self.gitlab_column,
						"id":str(uuid4()),
					}
				}
			)
			response.raise_for_status()

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
	pb = Productboard(username, password)
	gl = gitlab.Gitlab(GITLAB_URL, private_token=token)

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

		col_value = pb.get_gitlab_column_value(feature)
		if col_value and col_value.get('text_value'):
			click.echo(f"... feature already linked: {col_value['text_value']}")
		else:
			click.echo(f'... creating issue in {project}')
			gitlab_project = gitlab_projects[project]
			issue = gitlab_project.issues.create({
				'title': feature['name'],
				'description': f"{PRODUCTBOARD_FEATURE_URL}/{feature['id']}/detail\n\n{feature['description']}",
				'milestone_id': gitlab_milestone.id,
			})
			gitlab_url = f"https://gitlab.com/{project}/issues/{issue.iid}"
			pb.update_feature_gitlab(feature, gitlab_url)
			click.echo(f'... -> {gitlab_url}')

@cli.group('productboard')
def group_productboard():
	pass

@group_productboard.command('sync')
@click.option('--username')
@click.option('--password')
@click.option('--token')
@click.option('--release')
def productboard_sync(username, password, token, release):
	pb = Productboard(username, password)
	gl = gitlab.Gitlab(GITLAB_URL, private_token=token)

	pb.login()
	r = pb.get_release(release)
	if not r:
		raise click.UsageError('No such release')


if __name__ == '__main__':
	cli()
