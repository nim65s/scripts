#!/usr/bin/env python
"""
Clone and synchronize git organizations.
"""


import argparse
import datetime
import logging
import os
import pathlib
import subprocess
import sys

import httpx

API = "https://api.github.com"
ORGS = [
    "cmake-wheel",
    "stack-of-tasks",
    "gepetto",
    "humanoid-path-planner",
    "loco-3d",
]
LOG = logging.getLogger("gorg")


def dotget(data, key, default):
    """get key in data or default."""
    for part in key.split("."):
        if part in data:
            data = data[part]
        else:
            return default
    return data


def main(token, orgs, page):
    LOG.debug(f"main {token=} {orgs=}")
    headers = {"Authorization": f"Bearer {token}"}
    tree = {}
    for org in orgs:
        tree[org] = {}
        org_dir = pathlib.Path(org)
        if not org_dir.is_dir():
            LOG.error("%s is not a directory", org_dir)
            sys.exit(1)
        while page:
            resp = httpx.get(
                f"{API}/orgs/{org}/repos", params={"page": page}, headers=headers
            )
            if resp.status_code != 200:
                LOG.error(f"Can't get {org} repos page {page}: {resp}")
                continue
            if not resp.json():
                LOG.info(f"{org} repos page {page} is empty")
                page = False
                continue
            for repo in resp.json():
                name = repo["name"]
                repo_dir = org_dir / name
                if repo["archived"]:
                    LOG.info("Ignore archived %s", repo_dir)
                    tree[org][name] = "Archived"
                elif repo_dir.is_dir():
                    git_dir = repo_dir / ".git"
                    if git_dir.is_dir():
                        mtime = datetime.datetime.fromtimestamp(git_dir.stat().st_mtime)
                        if datetime.datetime.now() - mtime > datetime.timedelta(days=1):
                            LOG.info("Fetch %s", repo_dir)
                            subprocess.run(
                                ["git", "fetch", "--all", "--prune"], cwd=repo_dir
                            )
                            tree[org][name] = "Fethed"
                        else:
                            LOG.info("Skip %s", repo_dir)
                            tree[org][name] = "Skipped"

                    else:
                        LOG.warning("%s is not a git dir ?", repo_dir)
                        tree[org][name] = "???"
                else:
                    LOG.info("Clone %s", repo_dir)
                    subprocess.run(
                        ["git", "clone", "--recursive", f"gh:{org}/{name}"], cwd=org_dir
                    )
                    tree[org][name] = "Cloned"
            page += 1
    print()
    for org, repos in tree.items():
        print(f"+ {org}")
        for repo, status in repos.items():
            print(f"    + {repo:<25} {status}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-t", "--token")
    parser.add_argument("-p", "--page", type=int, default=1)
    # parser.add_argument("--gl-token")  # TODO
    parser.add_argument("orgs", nargs="*", default=ORGS)
    args = parser.parse_args()
    if args.verbose == 0:
        level = os.environ.get("CMEEL_LOG_LEVEL", "WARNING")
    else:
        level = 30 - 10 * args.verbose
    logging.basicConfig(level=level)
    main(
        args.token
        or os.environ.get(
            "GITHUB_TOKEN",
            subprocess.check_output(
                os.environ.get("GITHUB_TOKEN_CMD", "rbw get github-token").split(),
                text=True,
            ).strip(),
        ),
        # args.gl_token or os.environ["GITLAB_TOKEN"],
        args.orgs,
        args.page,
    )
