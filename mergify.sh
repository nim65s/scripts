#!/usr/bin/env bash

set -euo pipefail

if [[ $1 == https* ]]
then
    OWNER="$(echo "$1" | cut -d/ -f4)"
    REPO="$(echo "$1" | cut -d/ -f5)"
    PR="$(echo "$1" | cut -d/ -f7)"
else
    OWNER=$1
    REPO=$2
    PR=$3
fi
GITHUB_TOKEN=$(rbw get github-token)
REF=$(curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$OWNER/$REPO/pulls/$PR" | jq -r .head.sha)

for suite in $(curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/$OWNER/$REPO/commits/$REF/check-suites" | jq -r '.check_suites[] | .check_runs_url')
do
    for run in $(curl -L \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "$suite" | jq '.check_runs[] | .name' | sed 's/ / /g')
    do
        echo "      - check-success = $run" | sed 's/ / /g'
    done
done | sort -u | grep -v 'check-success = "Summary"'
