#!/usr/bin/env python3
"""
Task in a Stack

Keep track of a task in a stack:
- create an i3 workspace for it
- log its title, its creation, and its closing

obviously not related about https://github.com/stack-of-tasks/
"""

import argparse
from datetime import datetime
from os.path import expanduser

import i3ipc


def log(name: str, done: bool = False):
    """Append task name / status to a log file"""
    done = ' :: done' if done else ''
    with open(expanduser('~/.local/task-in-a-stack.log'), 'a') as f:
        print(f'{datetime.now()} | {name}{done}', file=f)


parser = argparse.ArgumentParser(description='keep track of a task in a stack')
parser.add_argument('-d', '--done', action='store_true', help='log that the task of the current workspace is done')
parser.add_argument('name', nargs='*', help='name for the new task')

if __name__ == '__main__':
    args = parser.parse_args()
    i3 = i3ipc.Connection()
    if args.done:
        log(i3.get_tree().find_focused().workspace().name, True)
    else:
        name = ' '.join(args.name)
        i3.command(f'workspace {name}')
        log(name)
