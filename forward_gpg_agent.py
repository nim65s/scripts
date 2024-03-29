#!/usr/bin/env python3

import os
import shelve
import sys
from argparse import ArgumentParser
from pathlib import Path
from subprocess import check_call, check_output

SHELF = (
    Path(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")))
    / "forward-gpg-agent"
)

parser = ArgumentParser(description="forward gpg agent sockets")
parser.add_argument("remote_host", nargs=1)
parser.add_argument("--down", action="store_true")
parser.add_argument("--verbose", action="store_true")


def forward_gpg_sockets(remote_host, down=False, verbose=False):
    here = check_output(["gpgconf", "--list-dir"]).decode().split()
    here_gpg = Path(
        next(l.split(":")[1] for l in here if l.startswith("agent-socket:"))
    )
    here_ssh = Path(
        next(l.split(":")[1] for l in here if l.startswith("agent-ssh-socket:"))
    )

    with shelve.open(str(SHELF)) as shelf:
        if remote_host[0] in shelf:
            there = shelf[remote_host[0]]
        else:
            there = (
                check_output(
                    ["ssh", remote_host[0], "gpgconf", "--list-dir"], stdin=sys.stdin
                )
                .decode()
                .split()
            )
            shelf[remote_host[0]] = there
    there_gpg = next(l.split(":")[1] for l in there if l.startswith("agent-socket:"))
    there_ssh = next(
        l.split(":")[1] for l in there if l.startswith("agent-ssh-socket:")
    )

    if down:
        if here_gpg.exists():
            here_gpg.unlink()
        if here_ssh.exists():
            here_ssh.unlink()
        gpg = f"{here_gpg}:{there_gpg}"
        ssh = f"{here_ssh}:{there_ssh}"
    else:
        # check_call(['ssh', remote_host[0], 'rm', there_gpg, there_ssh], stdin=sys.stdin)
        gpg = f"{there_gpg}:{here_gpg}"
        ssh = f"{there_ssh}:{here_ssh}"

    if verbose:
        print(f"ssh -L {ssh} {remote_host[0]}")
    print(f"ssh -L {gpg} {remote_host[0]}")
    check_call(["ssh", "-L", ssh, remote_host[0]], stdin=sys.stdin)


if __name__ == "__main__":
    forward_gpg_sockets(**vars(parser.parse_args()))
