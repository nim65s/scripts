#!/usr/bin/env python
from datetime import datetime, timedelta
from os import environ

from gitlab import Gitlab

MIN = datetime.now() - timedelta(days=365 * 2)
URL = "https://gitlab.laas.fr"

gl = Gitlab(url=URL, private_token=environ["TOKEN"])
gl.auth()

for project in gl.projects.list(as_list=False):
    if datetime.fromisoformat(project.last_activity_at[:-1]) < MIN:
        if project.namespace["kind"] == "group" and not project.archived:
            print(project.namespace["name"], project.name)
