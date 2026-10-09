#!/usr/bin/env python
"""
Get releases info for a repo
"""

import argparse
import datetime as dt
import itertools
import logging
import os
import pathlib
import subprocess

import httpx

API = "https://api.github.com"
LOG = logging.getLogger("gh-changelog")
HEADER = """# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]
"""


def main(token, owner, repo, page):
    LOG.debug(f"main {token=} {owner=} {repo=} {page=}")
    headers = {"Authorization": f"Bearer {token}"}
    versions = []
    print(HEADER)
    while page:
        resp = httpx.get(
            f"{API}/repos/{owner}/{repo}/releases",
            params={"page": page},
            headers=headers,
        )
        if resp.status_code != 200:
            LOG.error(f"Can't get {owner}/{repo} releases page {page}: {resp}")
            continue
        if not resp.json():
            LOG.info(f"{owner}/{repo} releases page {page} is empty")
            page = False
            continue
        for release in resp.json():
            if release["draft"]:
                continue
            tag = release["tag_name"].removeprefix("v")
            versions.append(tag)
            # fixed in python < 3.11 can't deal with Z
            published_at = release["published_at"].removesuffix("Z")
            date = dt.datetime.fromisoformat(published_at).strftime("%Y-%m-%d")
            if release.get("body"):
                body = release["body"].replace("\r", "")
                body = body.replace("\n# ", "\n### ")
                body = body.replace("\n## ", "\n### ")
                if body.startswith("# "):
                    body = f"##{body}"
                elif body.startswith("## "):
                    body = f"#{body}"
            else:
                body = ""
            print(f"## [{tag}] - {date}")
            print()
            print(body)
            print()
        page += 1
    print(
        f"[Unreleased]: https://github.com/{owner}/{repo}/compare/v{versions[0]}...HEAD"
    )
    for new, old in itertools.pairwise(versions):
        print(f"[{new}]: https://github.com/{owner}/{repo}/compare/v{old}...v{new}")
    print(
        f"[{versions[-1]}]: https://github.com/{owner}/{repo}/releases/tag/v{versions[-1]}"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="count", default=0)
    parser.add_argument("-t", "--token")
    parser.add_argument("-p", "--page", type=int, default=1)
    parser.add_argument("owner", default=pathlib.Path.cwd().parent.name)
    parser.add_argument("repo", default=pathlib.Path.cwd().name)
    args = parser.parse_args()
    if args.verbose == 0:
        level = os.environ.get("LOG_LEVEL", "WARNING")
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
        args.owner,
        args.repo,
        args.page,
    )
