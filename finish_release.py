#!/usr/bin/env python3
"""
Finish a release, after it has been pushed to robotpkg:
    - find the last release tag
    - check devel & stable status
    - update stable with the tag, then devel with stable
    - push the tag, devel & stable
    - get the distfiles in /tmp
    - show the url for creating a release on github
    - show the version message from robotpkg
"""

from argparse import ArgumentParser
from os import chdir, environ, getcwd
from os.path import expanduser
from pathlib import Path
from re import match
from shutil import copy
from subprocess import check_call, check_output

import httpx

_branches = check_output("git branch -a".split()).decode()
STABLE = next(b for b in ["stable", "master", "main"] if b in _branches)
BRANCHES = ["devel", STABLE]
RPKG = Path("/usr/local/openrobots/distfiles")
CWD = Path(getcwd())
if CWD.name == "build":
    chdir("..")
    CWD = Path(getcwd())

parser = ArgumentParser()
parser.add_argument("namespace", nargs="?", default=CWD.parent.name)
parser.add_argument("project", nargs="?", default=CWD.name)
parser.add_argument(
    "--robotpkg", type=Path, default=Path(expanduser("~/local/robotpkg/robotpkg"))
)
parser.add_argument("--wip", action="store_true")
parser.add_argument("--private", action="store_true")
parser.add_argument("-c", "--check-only", action="store_true")
parser.add_argument("--suffix", default="")
args = parser.parse_args()

if args.suffix:
    args.suffix = f"-{args.suffix}"

FROM_LAAS = True
try:
    chdir(RPKG)
    chdir(CWD)
except FileNotFoundError:
    FROM_LAAS = False

REMOTES = (
    {
        "origin": f"gl:gsaurel/{args.project}",
        "main": f"gl:{args.namespace}/{args.project}",
    }
    if args.private
    else {
        "origin": f"gh:nim65s/{args.project}",
        "main": f"gh:{args.namespace}/{args.project}",
        "gl": f"gl:{args.namespace}/{args.project}",
    }
)


def check_call_v(cmd: str, *args, **kwargs):
    """Verbose check_call"""
    sp = " \t\r\n"
    cmd_v = " ".join(f'"{arg}"' if any(c in arg for c in sp) else arg for arg in cmd)
    print(f"+ {cmd_v}")
    check_call(cmd, *args, **kwargs)


def check_call_s(cmd: str, *args, **kwargs):
    """simple .split() on cmd"""
    check_call_v(cmd.split(), *args, **kwargs)


def check_remotes():
    "Check that the project complies to the template"
    out = check_output("git remote -v".split()).decode()
    wrong = []
    for remote, url in REMOTES.items():
        expected = f"{remote}\t{url}"
        if expected not in out:
            wrong.append(expected)
    if wrong:
        print("Wrong remotes ! Currently got:")
        check_call_v(["git", "remote", "-v"])
        err = "Required remotes: \n" + "\n".join(wrong)
        raise EnvironmentError(err)


def get_release():
    "get the tag name of the latest release"
    tags = check_output("git tag -l".split()).decode().splitlines()
    major, minor, patch = sorted(
        [int(v) for v in tag[1:].split(".")]
        for tag in tags
        if match(r"^v\d+\.\d+\.\d+$", tag)
    )[-1]
    return f"v{major}.{minor}.{patch}"


def ndiff(a, b):
    "get the number of commits from a to b"
    return len(
        check_output(f"git rev-list {a}..{b}".split()).decode().strip().splitlines()
    )


def update_branches():
    "pull changes from the main remotes in the local branches"
    for branch in BRANCHES:
        for remote in REMOTES.keys():
            if ndiff(branch, f"{remote}/{branch}") > 0:
                if ndiff(f"{remote}/{branch}", branch) > 0:
                    raise RuntimeError(f"{branch} and {remote}/{branch} have diverged")
                else:
                    check_call_s(f"git checkout {branch}")
                    check_call_s(f"git pull {remote} {branch}")


def merge_release(release):
    "merge the latest release into stable, and then stable into devel"
    check_call_s(f"git checkout {STABLE}")
    check_call_s(f"git merge {release}")
    check_call_s("git checkout devel")
    check_call_s(f"git merge {STABLE}")


def download(version):
    "download the released tarball and its gpg signature from robotpkg"
    robotpkg_project = args.project.replace("_", "-")

    def dl(project):
        for ext in ["tar.gz", "tar.gz.sig"]:
            filename = f"{project}{args.suffix}-{version}.{ext}"
            if FROM_LAAS:
                copy(RPKG / robotpkg_project / filename, "/tmp")
            else:
                with (Path("/tmp") / filename).open("wb") as f:
                    url = f"https://www.openrobots.org/distfiles/{robotpkg_project}/{filename}"
                    with httpx.stream("GET", url) as r:
                        r.raise_for_status()
                        for chunk in r.iter_bytes():
                            f.write(chunk)
        full_filename = f"/tmp/{project}{args.suffix}-{version}.tar.gz"
        check_call_s(f"gpg --verify {full_filename}.sig")
        return full_filename

    try:
        return dl(args.project)
    except httpx.HTTPError:
        return dl(args.project.replace("-", "_"))


def get_message(release):
    "get the release message from robotpkg"
    robotpkg_project = args.project.replace("_", "-").replace(
        "dynamic-graph-python", "py-dynamic-graph"
    )
    cwd = args.robotpkg / "wip" if args.wip else args.robotpkg
    for suffix in [args.suffix, "-v3"]:
        contents = [f"{robotpkg_project}{suffix}]", release]
        print(
            f'looking for "{contents}" in', "robotpkg-wip" if args.wip else "robotpkg"
        )
        for line in (
            check_output("git log --oneline".split(), cwd=cwd).decode().splitlines()
        ):
            if all(content in line for content in contents):
                commit = line.split()[0].replace("\x1b[33m", "").replace("\x1b[m", "")
                m = check_output(f"git show -s {commit}".split(), cwd=cwd).decode()
                return "\n".join([line.strip() for line in m.split("\n")[6:]])


def main():
    print(f"--- Checking remotes for {args.namespace}/{args.project } ---")
    check_remotes()
    if args.check_only:
        return
    release = get_release()
    print(f"=== RELEASING {args.namespace}/{args.project }, {release} ===")
    print(check_output("git status".split()).decode())
    check_call_s("git fetch --all --prune")

    print("Updating local branches…")
    update_branches()

    print(check_output("git status".split()).decode())

    print("Merging release…")
    merge_release(release)

    print("Pushing…")
    for remote in REMOTES.keys():
        check_call_s(f"git push {remote} devel {release} {STABLE}")

    print("Downloading files…")
    filename = download(release[1:])
    print("Getting message…")
    message = get_message(release) or ""
    print("Getting github token")
    github_token = check_output(["pass", "web/github/ghcli-token"]).decode().strip()
    print("Publishing release draft…")

    check_call_v(
        [
            "gh",
            "release",
            "create",
            "-d",
            "-n",
            message,
            "-t",
            f"Release {release}",
            "-R",
            f"{args.namespace}/{args.project}",
            release,
            filename,
            f"{filename}.sig",
        ],
        env={"GITHUB_TOKEN": github_token, **environ},
    )


if __name__ == "__main__":
    main()
