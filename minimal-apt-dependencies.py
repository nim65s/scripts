#!/usr/bin/env python3
"""
Take a set of apt packages, and remove those which are already dependencies of others.
"""

from argparse import ArgumentParser
from subprocess import check_output, DEVNULL
from typing import Set


parser = ArgumentParser(description=__doc__)
parser.add_argument("pkgs", nargs="+")


def apt_depends(pkg: str) -> Set[str]:
    """Get the list of dependencies of "pkg", plus some garbage we don't care about."""
    deps = set(check_output(["apt", "depends", pkg], text=True, stderr=DEVNULL).split())
    deps.remove(pkg)
    return deps


def apt_filter(pkgs: Set[str]) -> Set[str]:
    """Filter "pkgs", to ensure the set is minimal."""
    dependencies = set()
    for pkg in pkgs:
        dependencies |= apt_depends(pkg)
    return set(pkg for pkg in pkgs if pkg not in dependencies)


if __name__ == "__main__":
    args = parser.parse_args()
    print(apt_filter(args.pkgs))
