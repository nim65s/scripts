#!/usr/bin/env python2
#-*- coding: utf-8 -*-

import sys

import i3


def focused(workspace):
    if workspace['focused']:
        return workspace

workspaces = i3.get_workspaces()
current_ws = filter(focused, workspaces)[0]['num']

ws_list = range(current_ws + 1, 11) + range(1, current_ws)
print ws_list

if len(sys.argv) > 1:
    ws_list.reverse()

used_ws = [ws['num'] for ws in i3.get_workspaces()]
print used_ws

for ws in ws_list:
    print ws
    if ws not in used_ws:
        print ws
        i3.command('workspace', str(ws))
        break
