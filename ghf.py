#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["PyGithub"]
# ///

"""
Configure clone of fork(s):
- fork the upstream if it is not already forked
- clone the fork if it is not already cloned
- get inside the clone if not already inside
- remove `origin` remote
- configure `upstream` and `me` remotes
- fetch
- configure pull from upstream
- configure push to fork
"""

from logging import basicConfig, getLogger
from argparse import ArgumentParser
from pathlib import Path
from os import environ
from subprocess import check_output, DEVNULL, run

from github import Auth, Github
from github.GithubException import UnknownObjectException

logger = getLogger("ghf")

parser = ArgumentParser()
parser.add_argument(
    "repo", default=".", help="the current directory (.), or repo, or org/repo, or org/"
)
parser.add_argument("branch", nargs="?", help="the branch to work on")
parser.add_argument(
    "--token-cmd",
    default="rbw get github-token",
    help="github token is required. "
    "Pass it through GITHUB_TOKEN env var, or provide a command to get it",
)
parser.add_argument(
    "--github-url", default="gh:", help="eg. 'git@github.com:' or 'https://github.com/'"
)
parser.add_argument(
    "-v",
    "--verbose",
    action="count",
    default=int(environ.get("VERBOSITY", 0)),
    help="increment verbosity level",
)


def vrun(*cmd, **kwargs):
    logger.info("+ %s", " ".join(*cmd))
    run(*cmd, **kwargs)


def get_repo(gh: Github, repo: str, me: str) -> (str, str):
    if "/" in repo:
        upstream, name = repo.split("/")
        try:
            gh.get_repo(f"{me}/{name}")
        except UnknownObjectException:
            logger.info("Forking '%s/%s into '%s/%s'...", upstream, name, me, name)
            gh.get_repo(f"{upstream}/{name}").create_fork()
            logger.info("Forked '%s/%s into '%s/%s'.", upstream, name, me, name)
    else:
        name = Path.cwd().name if repo == "." else repo
        ghr = gh.get_repo(f"{me}/{name}")
        upstream = ghr.parent.owner.login if ghr.fork else me

    logger.debug("working on %s's fork of %s/%s", me, upstream, name)
    return upstream, name


def clone(upstream: str, me: str, name: str, branch: str, github_url: str):
    # clone the fork if it is not already cloned
    # get inside the clone if not already inside

    if Path.cwd().name == name and Path(".git").exists():
        git = ["git"]
        logger.debug("Using already cloned current directory")
    else:
        git = ["git", "-C", name]
        if Path(name).exists() and (Path(name) / ".git").exists():
            logger.debug("Using already cloned %s directory", name)
        else:
            clone = ["git", "clone"]
            if branch:
                clone = [*clone, "--branch", branch]
            logger.info("Cloning '%s/%s'...", me, name)
            vrun([*clone, f"{github_url}{me}/{name}"], check=True)
            logger.info("Cloned '%s/%s'.", me, name)

    # remove `origin` remote
    vrun([*git, "remote", "remove", "origin"], stderr=DEVNULL)

    # configure `upstream` and `me` remotes
    for remote, url in [
        ("upstream", f"{github_url}{upstream}/{name}"),
        ("me", f"{github_url}{me}/{name}"),
    ]:
        if url not in check_output([*git, "remote", "show", "-n", remote], text=True):
            vrun([*git, "remote", "remove", remote], stderr=DEVNULL)
            logger.debug("Creating remote %s", remote)
            vrun([*git, "remote", "add", remote, url], check=True)

    # fetch
    logger.debug("Updating upstream/me remotes")
    vrun([*git, "fetch", "--all", "--prune"])

    # configure pull from upstream
    if not branch:
        logger.debug("Get current branch")
        branch = check_output([*git, "branch", "--show-current"], text=True).strip()
    logger.info("Configure %s to be pulled from upstream", branch)
    vrun([*git, "branch", f"--set-upstream-to=upstream/{branch}", branch], check=True)
    for b in check_output([*git, "branch", "-a"], text=True).split("\n"):
        if "remotes/upstream/HEAD" not in b:
            continue
        main_branch = b.strip().split("/")[-1]
        if main_branch == branch:
            break
        logger.info("Configure %s to be pulled from upstream", main_branch)
        vrun([*git, "switch", "-C", main_branch, "-t", "upstream"], check=True)
        vrun([*git, "switch", branch], check=True)
        break

    # configure push to me
    logger.info("Configure pushes to fork")
    vrun([*git, "config", "remote.pushDefault", "me"], check=True)


def main(gh: Github, repo: str, branch: str, github_url: str, **kwargs):
    me = gh.get_user().login

    if repo.endswith("/"):
        upstream = repo.removesuffix("/")
        org = gh.get_organization(upstream)
        for repo in org.get_repos():
            if not repo.archived:
                upstream, name = get_repo(gh, f"{upstream}/{repo.name}", me)
                clone(upstream, me, name, branch, github_url)
    else:
        upstream, name = get_repo(gh, repo, me)
        clone(upstream, me, name, branch, github_url)


if __name__ == "__main__":
    args = parser.parse_args()
    basicConfig(level=50 - 10 * args.verbose)
    logger.debug("%s", args)
    auth = Auth.Token(
        environ.get(
            "GITHUB_TOKEN", check_output(args.token_cmd.split(), text=True).strip()
        )
    )

    with Github(auth=auth) as gh:
        main(gh, **vars(args))
