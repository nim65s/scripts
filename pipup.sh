#!/usr/bin/fish

pip install -U pip
pip-compile
git diff requirements.txt | grep '^-\|^+'
pip-sync
git add requirements.txt
git commit -m "pip-update"
git push
