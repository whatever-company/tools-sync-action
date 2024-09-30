#!/usr/bin/env python

import contextlib
import json
import re
from collections.abc import Iterable
from typing import Any, Literal, TypedDict, cast

import click
import requests
import semver
from dotenv import load_dotenv
from github import Commit, Github, GithubException, Issue, Repository

# Load dot file as ENV
load_dotenv()

ISSUE_RE = re.compile("#([0-9]+)")

GITHUB_ORGANISATION = "whatever-company"
ZENDESK_TICKET_RE = re.compile("ZD-([0-9]+)", re.IGNORECASE)
ZENDESK_URL = "https://knowledgeplaza.zendesk.com"
ZENDESK_CS_TEAM_ID = 22392423
ZENDESK_BUGS_TEAM_ID = 360003060151

PROJECT_TO_EMOJI = {
    "elium-web": "⚛️",
    "elium-backend": "⚙️",
    "elium-mobile": "📞",
    "website": "🌍",
    "learn": "📄",
    # 'infra/...': '🏗',
}


def get_issues_from_commits(project: Repository.Repository, commits: list[Commit.Commit]) -> list[Issue.Issue]:
    issues_ids: set[str] = set()
    for commit in commits:
        match = ISSUE_RE.findall(commit.commit.message)
        issues_ids = issues_ids.union(set(match))
    issues: list[Issue.Issue] = []
    for i in issues_ids:
        with contextlib.suppress(GithubException):
            issues.append(project.get_issue(int(i)))
    return issues


class ZendeskTicket(TypedDict):
    id: int
    status: str
    tags: list[str]


class Zendesk:
    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password

    def update_tickets(self, ids: list[str], payload: dict[str, Any]) -> requests.Response:
        # https://developer.zendesk.com/rest_api/docs/support/tickets#request-body

        return requests.put(
            f"{ZENDESK_URL}/api/v2/tickets/update_many.json",
            params={"ids": ",".join(ids)},
            json=payload,
            auth=(self.username, self.password),
            timeout=10,
        )

    def get_tickets(self, ids: Iterable[str]) -> list[ZendeskTicket] | None:
        tickets = requests.get(
            f"{ZENDESK_URL}/api/v2/tickets/show_many.json",
            params={"ids": ",".join(ids)},
            auth=(self.username, self.password),
            timeout=10,
        ).json()

        click.echo(f"tickets received from ZD: {tickets}")
        if "tickets" not in tickets:
            return None
        return tickets["tickets"]

    def get_ticket_ids_from_str(self, text: str) -> list[str]:
        return ZENDESK_TICKET_RE.findall(text)


@click.group()
def cli() -> None:
    pass


class ContextObj(TypedDict):
    dry_run: bool
    repository: Repository.Repository
    to_ref: str
    from_ref: str
    status: str
    diff_link: str | None
    commits: list[Commit.Commit]
    issues: list[Issue.Issue]


@cli.group("from_github", chain=True)
@click.option("--token", envvar="GH_TOKEN")
@click.option("--project", envvar="GH_PROJECT")
@click.option("--from-ref", envvar="FROM_REF")
@click.option("--to-ref", envvar="TO_REF")
@click.option("--status", envvar="STATUS", type=click.Choice(["production", "staging", "development"]))
@click.option("--linear", envvar="LINEAR_RELEASE", help="Staging is always further or eq than prod")
@click.option("--dry-run", is_flag=True)
@click.pass_context
def group_from_github(
    ctx: click.Context,
    token: str,
    project: str,
    from_ref: str,
    to_ref: str,
    status: Literal["production", "staging", "development"],
    linear: bool,  # noqa: FBT001
    dry_run: bool,  # noqa: FBT001
) -> None:
    click.secho("Start setup", fg="green", underline=True)
    click.echo(f"received from_ref={from_ref} to_ref={to_ref} status={status}")

    ctx.ensure_object(dict)
    ctx_obj = cast(ContextObj, ctx.obj)

    # pass down some var
    ctx_obj["dry_run"] = dry_run

    gh_client = Github(token)
    ctx_obj["repository"] = gh_client.get_repo(project)

    ctx_obj["to_ref"] = to_ref
    if not from_ref and to_ref.startswith("v"):
        click.echo(f"Process preceding version of {to_ref}")
        current_version = semver.parse_version_info(to_ref[1:])
        tags = ctx_obj["repository"].get_tags()
        previous_version = semver.parse_version_info("0.0.0")
        for git_tag in tags:
            try:
                tag_version = semver.parse_version_info(git_tag.name[1:])
            except ValueError:
                continue
            if not linear and (
                (current_version.prerelease and not tag_version.prerelease)
                or (not current_version.prerelease and tag_version.prerelease)
            ):
                # only tag pre release toghether or release toghether
                continue
            if tag_version < current_version and tag_version > previous_version:
                previous_version = tag_version
        from_ref = f"v{previous_version}"
        click.echo(f"Found from {from_ref}")

    ctx_obj["from_ref"] = from_ref
    ctx_obj["status"] = status

    if from_ref and to_ref and project:
        click.secho(f"From {from_ref} to {to_ref}", fg="green")
        compare = ctx_obj["repository"].compare(from_ref, to_ref)
        ctx_obj["diff_link"] = compare.html_url
        ctx_obj["commits"] = list(compare.commits)
    else:
        ctx_obj["commits"] = []
        ctx_obj["diff_link"] = None
    click.echo(ctx_obj["commits"])
    click.echo("Fetching Issues")

    ctx_obj["issues"] = get_issues_from_commits(ctx_obj["repository"], ctx_obj["commits"])

    click.echo(f"{len(ctx_obj['issues'])} GitHub Issues found")


@group_from_github.command("to_zendesk")
@click.option("--zd-username", envvar="ZD_USERNAME")
@click.option("--zd-password", envvar="ZD_PASSWORD")
@click.pass_context
def to_zendesk(ctx: click.Context, zd_username: str, zd_password: str) -> None:
    click.secho("Sync to Zendesk", fg="green", underline=True)
    ctx_obj = cast(ContextObj, ctx.obj)
    status = ctx_obj["status"]

    if status not in ("production", "staging", "development"):
        click.echo(f"Not syncing status {status}")
        return

    zd = Zendesk(zd_username, zd_password)

    zd_ticket_ids: set[str] = set()
    issue_to_commit: dict[str, Commit.Commit] = {}

    # Find Zendesk issues in commit messages
    for commit in ctx_obj["commits"]:
        click.echo(f"Processing: {commit.sha}")
        zd_ids_found = zd.get_ticket_ids_from_str(commit.commit.message)
        zd_ticket_ids = zd_ticket_ids.union(zd_ids_found)
        if zd_ids_found:
            click.echo(f"Found {zd_ids_found}")
            for zd_id in zd_ids_found:
                issue_to_commit[zd_id] = commit

    # Find Zendesk issues ids
    for issue in ctx_obj["issues"]:
        # probably never more than 1 but let's be safe
        click.echo(f"Processing: {issue.title}")
        zd_ids_found = zd.get_ticket_ids_from_str(issue.title)
        zd_ticket_ids = zd_ticket_ids.union(zd_ids_found)
        if zd_ids_found:
            click.echo(f"Found {zd_ids_found}")

    # Update zendesk only for given stages
    if not zd_ticket_ids:
        click.echo("No zendesk issue to sync")
        return

    click.echo(f"Fetching tickets: {zd_ticket_ids}")

    tickets = zd.get_tickets(zd_ticket_ids)
    for ticket in tickets or []:
        commit = issue_to_commit.get(str(ticket["id"]))
        assert commit is not None
        payload = {
            "ticket": {
                "additional_tags": f"deployed-in-{status}",
                "comment": {
                    "html_body": f"""A fix was released in {status}<br />
                    <a href="{commit.html_url}" target="_blank">{commit.sha[0:7]}</a>
                    """,
                    "public": False,
                },
            }
        }

        click.echo(f'got {ticket["id"]} in status : {ticket["status"]}')

        # Avoid resync what's already synced
        if "deployed-in-production" in ticket["tags"]:
            click.echo(f'skip {ticket["id"]}, already in production')
            continue
        if "deployed-in-staging" in ticket["tags"] and status != "production":
            click.echo(f'skip {ticket["id"]}, already marked as synced in staging')
            continue
        if "deployed-in-development" in ticket["tags"] and status not in ("production", "staging"):
            click.echo(f'skip {ticket["id"]}, already marked as synced in development')
            continue

        if status == "production" and ticket["status"] not in ("closed", "solved"):
            payload["ticket"]["status"] = "open"

        click.echo(f'syncing ticket {ticket["id"]}')
        if not ctx_obj["dry_run"]:
            response = zd.update_tickets([str(ticket["id"])], payload)
            click.echo(f"ZD update: {response.text}")


@group_from_github.command("to_slack")
@click.option("--slack-url", envvar="SLACK_URL")
@click.pass_context
def to_slack(ctx: click.Context, slack_url: str) -> None:
    click.secho("Announcing release on slack", fg="green", underline=True)
    ctx_obj = cast(ContextObj, ctx.obj)
    status = ctx_obj["status"]
    project_name = ctx_obj["repository"].name
    project_icon = PROJECT_TO_EMOJI.get(project_name, "")
    if status not in ("production", "staging"):
        click.echo("Announcing only prod/staging release")
        return

    diff_link = ctx_obj["diff_link"]
    from_ref = ctx_obj["from_ref"]
    to_ref = ctx_obj["to_ref"]
    commits = ctx_obj["commits"]
    commits_titles = [f"<{commit.html_url}|{commit.sha[0:7]}> {commit.commit.message}" for commit in commits]
    commits_str = "\n".join(commits_titles)
    payload = {
        "attachments": [
            {
                "title": f"Deployed on {project_icon} {project_name} - {status} : {to_ref} \n ({len(commits)} commits)",
                "title_link": diff_link,
                "color": "#36a64f" if status == "production" else "#a5a5a5",
                "text": f"\n\n\n\n\n{commits_str}",
                "footer": f"diff: <{diff_link}|{from_ref}...{to_ref}>",
                "fields": [
                    {
                        "title": "Status",
                        "value": status,
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
                ],
            }
        ]
    }

    if not ctx_obj["dry_run"]:
        result = requests.post(slack_url, json=payload, timeout=10)
        click.echo("->")
        click.echo(result.text)
    else:
        click.echo(json.dumps(payload))


@group_from_github.command("to_test")
@click.pass_context
def to_test(ctx: click.Context) -> None:
    click.secho("Sync to TEST", fg="green", underline=True)
    ctx_obj = cast(ContextObj, ctx.obj)
    status = ctx_obj["status"]
    click.echo(f"syncing status {status}")
    for issue in ctx_obj["issues"]:
        click.echo(f"Found {issue.id}")


if __name__ == "__main__":
    cli()
