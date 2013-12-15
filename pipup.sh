#!/bin/bash

which pip2 && PIP=pip2 || PIP=pip

sudo $PIP install -r ~/dotfiles/requirements.txt --upgrade | grep -v "Requirement already up-to-date:"
