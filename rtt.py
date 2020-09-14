#!/usr/bin/env python3
"""
Recurrent Task Tracker.

Keep track of recurrent tasks:
- configure tasks with their period: "add" command
- track when one was last done: "done" command
- show which ones are late: "show" command (default)

obviously not related to
https://fr.wikipedia.org/wiki/R%C3%A9duction_du_temps_de_travail_en_France
"""

from argparse import ArgumentParser, RawDescriptionHelpFormatter
from dataclasses import dataclass
from datetime import datetime as dt
from datetime import timedelta
from json import JSONEncoder, dump, dumps, load, loads  # noqa - flake8 doesn't find doctests
from os.path import expanduser
from pathlib import Path
from typing import List

parser = ArgumentParser(description=__doc__, formatter_class=RawDescriptionHelpFormatter)
parser.add_argument('-t', '--test', action='store_true', help='run self tests')
parser.add_argument('-p', '--path', type=Path, default=expanduser('~/.local/rtt.json'), help='path to the database')
subparsers = parser.add_subparsers(title='commands')
parser_add = subparsers.add_parser('add', help='add a recurrent task to track')
parser_add.add_argument('name', type=str, help='name of the task')
parser_add.add_argument('period', type=int, help='period of the task in days')
parser_add.add_argument('description', type=str, nargs='*', help='description')
parser_done = subparsers.add_parser('done', help='when a task was done')
parser_done.add_argument('done', type=str, help='name of the task')
parser_show = subparsers.add_parser('show', help='show sorted tasks')

# First we need some utils to serialize datetime in JSON. Big deal.
# Let's hijack floats. What could possibly go wrong ?


class DateTimeEncoder(JSONEncoder):
    """A JSON encoder for datetime as timestamp floats.

    >>> dumps({'dt': dt(2020, 9, 13, 14, 26, 40)})
    Traceback (most recent call last):
        ...
    TypeError: Object of type 'datetime' is not JSON serializable

    >>> dumps({'dt': dt(2020, 9, 13, 14, 26, 40)}, cls=DateTimeEncoder)
    '{"dt": 1600000000.0}'
    """
    def default(self, o):
        """Add a dattime serialization."""
        return o.timestamp() if isinstance(o, dt) else JSONEncoder.default(self, o)


def ftodt(timestamp: str):
    """Decode JSON from timestamp floats to datetimes.

    >>> loads('{"dt": 1600000000.0}')
    {'dt': 1600000000.0}

    >>> loads('{"dt": 1600000000.0}', parse_float=ftodt)
    {'dt': datetime.datetime(2020, 9, 13, 14, 26, 40)}
    """
    return dt.fromtimestamp(float(timestamp))


# Next, we need a to define what is a recurrent task


@dataclass
class RecurrentTask:
    """Model a Recurrent Task."""
    name: str
    description: str
    period: int  # in days
    last: dt

    def __str__(self):
        """Pretty print this task."""
        return f'{self.remaining(): >7.3f}: {self.name:20} - {self.description}'

    def remaining(self, now=dt.now):
        """Relative remaining time left to do the task.

        >>> task = RecurrentTask('wake-up', 'every morning', 1, dt(2020, 9, 13, 14, 26, 40))
        >>> task.remaining(dt(2020, 9, 13, 14, 26, 40))  # The instant you've done it
        1.0
        >>> task.remaining(dt(2020, 9, 14, 14, 26, 40))  # the due date
        0.0
        >>> task.remaining(dt(2020, 9, 15, 14, 26, 40))  # the due date + 1 period
        -1.0
        >>> task = RecurrentTask('week-end', 'once a week', 7, dt(2020, 9, 13, 14, 26, 40))
        >>> task.remaining(dt(2020, 9, 17, 2, 26, 40))  # half a week before the due date
        0.5
        >>> task.remaining(dt(2020, 9, 20, 14, 26, 40))  # the due date
        0.0
        >>> task.remaining(dt(2020, 9, 24, 2, 26, 40))  # half a week after the due date
        -0.5
        """
        if callable(now):
            now = now()

        due = self.last + timedelta(days=self.period)
        return (due - now).total_seconds() / (self.period * 86400)


# Also, we need to save a list of those somewhere


def write_database(tasks: List[RecurrentTask], path: Path):
    """Write the tasks to the database."""
    with Path(path).open('w') as database:
        dump([task.__dict__ for task in tasks], database, cls=DateTimeEncoder, indent=2)


def read_database(path: Path) -> List[RecurrentTask]:
    """Read the tasks from the database.

    >>> tasks = [RecurrentTask('test', 'CI', 1, dt(2020, 9, 13, 14, 26, 40))]
    >>> write_database(tasks, '/tmp/rtt_test.json')
    >>> read_database('/tmp/rtt_test.json')
    [RecurrentTask(name='test', description='CI', period=1, last=datetime.datetime(2020, 9, 13, 14, 26, 40))]
    """
    with Path(path).open('r') as database:
        return [RecurrentTask(**task) for task in load(database, parse_float=ftodt)]


if __name__ == "__main__":
    args = parser.parse_args()
    if args.test:
        import doctest
        doctest.testmod(optionflags=doctest.IGNORE_EXCEPTION_DETAIL)
    else:
        try:
            tasks = read_database(args.path)
        except FileNotFoundError:
            tasks = []
        if hasattr(args, 'name'):
            tasks.append(RecurrentTask(args.name, ' '.join(args.description), args.period, dt.now()))
            write_database(tasks, args.path)
        elif hasattr(args, 'done'):
            task = next(task for task in tasks if task.name == args.done)
            task.last = dt.now()
            write_database(tasks, args.path)
        else:
            for task in sorted(tasks, key=lambda task: task.remaining(), reverse=True):
                print(task)
