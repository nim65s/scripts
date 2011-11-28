#!/bin/bash
tmux has-session -t "TearDrop" && tmux attach -t "TearDrop" || tmux new -s "TearDrop"
