#!/usr/bin/env python3
"""
Task in a Stack

Keep track of a task in a stack:
- create an i3 workspace for it
- log its title, its creation, and its closing
- reopen all unfinished tasks

obviously not related about https://github.com/stack-of-tasks/
"""

import argparse
from datetime import datetime
from os.path import expanduser

import i3ipc

DONE = ' :: done'
FILE = expanduser('~/.local/task-in-a-stack.log')


def log(name: str, done: bool = False):
    """Append task name / status to a log file"""
    done_str = DONE if done else ''
    with open(FILE, 'a') as f:
        print(f'{datetime.now()} | {name}{done_str}', file=f)


def reopen():
    """Reopen unfinished tasks"""
    stack = set()
    with open(FILE) as f:
        for line in f:
            task = line.strip().split('|')[1]
            if task.endswith(DONE):
                stack.discard(task[:-len(DONE)])
            else:
                stack.add(task)
    for task in stack:
        i3.command(f'workspace {task}')
        i3.command('exec i3-sensible-terminal')


parser = argparse.ArgumentParser(description='keep track of a task in a stack')
parser.add_argument('-d', '--done', action='store_true', help='log that the task of the current workspace is done')
parser.add_argument('-r', '--reopen', action='store_true', help='reopen unfinished tasks')
parser.add_argument('name', nargs='*', help='name for the new task')

if __name__ == '__main__':
    args = parser.parse_args()
    i3 = i3ipc.Connection()
    if args.done:
        log(i3.get_tree().find_focused().workspace().name, done=True)
    elif args.reopen:
        reopen()
    else:
        name = ' '.join(args.name)
        i3.command(f'workspace {name}')
        i3.command('exec kitty')
        log(name)
