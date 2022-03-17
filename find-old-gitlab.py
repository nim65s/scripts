#!/usr/bin/env python
from datetime import datetime, timedelta
from os import environ

from gitlab import Gitlab

NOW = datetime.now()
MAX = timedelta(days=365 * 2)
URL = "https://gitlab.laas.fr"

gl = Gitlab(url=URL, private_token=environ["TOKEN"])
gl.auth()

for project in gl.projects.list(as_list=False):
    dt = datetime.fromisoformat(project.last_activity_at[:-1])
    if NOW - dt > MAX and project.namespace["kind"] == "group":
        print(project.namespace["name"], project.name)
