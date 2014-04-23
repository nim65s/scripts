#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from __future__ import unicode_literals

import sys

import i3

argv = sys.argv

if argv[1] not in ['switch', 'move']:
    print "first arg must be switch or move"
    sys.exit(1)
if argv[2] not in ['prev', 'next']:
    print "second arg must be prev or next"
    sys.exit(2)


def focused(workspace):
    if workspace['focused']:
        return workspace

workspaces = i3.get_workspaces()
current_ws = filter(focused, workspaces)[0]['num']

ws_list = range(current_ws + 1, 11) + range(1, current_ws)

if argv[2] == 'prev':
    ws_list.reverse()

used_ws = [ws['num'] for ws in i3.get_workspaces()]

try:
    ws = next(ws for ws in ws_list if ws not in used_ws)
except StopIteration:
    sys.exit(3)

if argv[1] == 'switch':
    i3.command('workspace', str(ws))
else:
    i3.command('move container to workspace', str(ws))
