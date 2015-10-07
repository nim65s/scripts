#!/usr/bin/env python

from datetime import datetime
from os import environ
from os.path import expanduser
from pathlib import Path
from stat import S_IEXEC, S_IXGRP, S_IXOTH
from subprocess import PIPE, run

from peewee import CharField, DateTimeField, Model, SqliteDatabase

db = SqliteDatabase(str(Path(environ['XDG_CACHE_HOME'] if 'XDG_CACHE_HOME' in environ else expanduser('~/.cache')) / 'demunim'))


class Command(Model):
    name = CharField(unique=True)
    date = DateTimeField(null=True)

    class Meta:
        database = db

if __name__ == '__main__':
    db.connect()
    if not Command.table_exists():
        db.create_table(Command)
        with db.atomic():
            for d in environ['PATH'].split(':'):
                for f in Path(d).iterdir():
                    if f.is_file() and f.stat().st_mode & (S_IEXEC | S_IXGRP | S_IXOTH):
                        Command.create(name=f.name)

    executables = (c.name for c in Command.select().order_by(Command.date.desc()))
    out = run(['dmenu'], input='\n'.join(executables), stdout=PIPE, universal_newlines=True).stdout.strip()
    if out:
        command = Command.get_or_create(name=out)[0]
        command.date = datetime.now()
        command.save()

        run(out)
