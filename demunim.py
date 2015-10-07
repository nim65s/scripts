#!/usr/bin/env python

from datetime import datetime
from distutils.spawn import find_executable
from os import environ
from os.path import expanduser
from pathlib import Path
from stat import S_IEXEC, S_IXGRP, S_IXOTH
from subprocess import PIPE, run
from sys import argv

from sqlalchemy import Column, DateTime, Integer, String, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import exists

Base = declarative_base()


class Command(Base):
    __tablename__ = 'command'
    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    datetime = Column(DateTime)

    def __str__(self):
        return self.name


def setup_database():
    db = Path(environ['XDG_CACHE_HOME'] if 'XDG_CACHE_HOME' in environ else expanduser('~/.cache')) / 'demunim.sqlite'
    if not db.parent.is_dir():
        db.parent.mkdir(parents=True)
    engine = create_engine('sqlite:///%s' % db)
    Base.metadata.create_all(engine)
    Session = sessionmaker()
    Session.configure(bind=engine)
    return Session()


def get_executables():
    x = S_IEXEC | S_IXGRP | S_IXOTH
    return (f.name for d in environ['PATH'].split(':') for f in Path(d).iterdir() if f.is_file() and f.stat().st_mode & x)


def populate_database(session):
    for command in session.query(Command):
        if find_executable(command.name) is None:
            session.delete(command)
    for command in get_executables():
        if not session.query(exists().where(Command.name == command)).scalar():
            session.add(Command(name=command))
    session.commit()


if __name__ == '__main__':
    session = setup_database()

    if len(argv) > 1:
        populate_database(session)
    else:
        executables = (c.name for c in session.query(Command).order_by(Command.datetime.desc()).all())
        out = run(['dmenu'], input='\n'.join(executables), stdout=PIPE, universal_newlines=True).stdout.strip()
        if out:
            command = session.query(Command).filter(Command.name == out).first()
            if command is None:
                command = Command(name=out)
                session.add(command)
            command.datetime = datetime.now()
            session.commit()

            run(out)