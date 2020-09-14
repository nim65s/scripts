#!/usr/bin/env python3
"""
Recurrent Task Tracker

Keep track of recurrent tasks:
- configure tasks with their period
- track when one was last done
- show which ones are late

obviously not related to
https://fr.wikipedia.org/wiki/R%C3%A9duction_du_temps_de_travail_en_France
"""

from argparse import ArgumentParser, RawDescriptionHelpFormatter
from datetime import datetime as dt
from json import JSONEncoder, dump, dumps, load, loads
from os.path import expanduser
from pathlib import Path

parser = ArgumentParser(description=__doc__, formatter_class=RawDescriptionHelpFormatter)
parser.add_argument('-t', '--test', action='store_true', help='run self tests')
parser.add_argument('-p', '--path', type=Path, default=expanduser('~/.local/rtt.json'), help='path to the database')

# First we need to serialize datetime in JSON. Big deal.
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
        """Main method to overwrite."""
        return o.timestamp() if isinstance(o, dt) else JSONEncoder.default(self, o)


def ftodt(timestamp: str):
    """A JSON decoder from timestamp floats to datetimes

    >>> loads('{"dt": 1600000000.0}')
    {'dt': 1600000000.0}

    >>> loads('{"dt": 1600000000.0}', parse_float=ftodt)
    {'dt': datetime.datetime(2020, 9, 13, 14, 26, 40)}
    """
    return dt.fromtimestamp(float(timestamp))


# Next, we need a database of tasks, periods and last occurences


def write_database(data, path: Path):
    """Write the data to the database."""
    with path.open('w') as database:
        dump(data, database, cls=DateTimeEncoder)


def read_database(path: Path):
    """Write the data from the database.

    >>> data = [{'test': dt(2020, 9, 13, 14, 26, 40)}]
    >>> write_database(data, Path('/tmp/rtt_test.json'))
    >>> read_database(Path('/tmp/rtt_test.json'))
    [{'test': datetime.datetime(2020, 9, 13, 14, 26, 40)}]
    """
    with path.open('r') as database:
        return load(database, parse_float=ftodt)


if __name__ == "__main__":
    args = parser.parse_args()
    if args.test:
        import doctest
        doctest.testmod()
