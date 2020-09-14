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

import argparse
import datetime
import json

parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
parser.add_argument('-t', '--test', action='store_true', help='run self tests')

# First we need to serialize datetime in JSON. Big deal.


class DateTimeEncoder(json.JSONEncoder):
    """An encoder for datetime.

    >>> json.dumps({'dt': datetime.datetime(2020, 9, 14, 18, 46, 40)})
    Traceback (most recent call last):
        ...
    TypeError: Object of type 'datetime' is not JSON serializable

    >>> json.dumps({'dt': datetime.datetime(2020, 9, 14, 18, 46, 40)}, cls=DateTimeEncoder)
    '{"dt": 1600102000.0}'
    """
    def default(self, o):
        """Main method to overwrite."""
        if isinstance(o, datetime.datetime):
            return o.timestamp()
        return json.JSONEncoder.default(self, o)


def stodt(timestamp: str):
    """A decoder for float to datetime

    >>> json.loads('{"dt": 1600102000.0}')
    {'dt': 1600102000.0}

    >>> json.loads('{"dt": 1600102000.0}', parse_float=stodt)
    {'dt': datetime.datetime(2020, 9, 14, 18, 46, 40)}
    """
    return datetime.datetime.fromtimestamp(float(timestamp))


if __name__ == "__main__":
    args = parser.parse_args()
    if args.test:
        import doctest
        doctest.testmod()
    else:
        print('fail')
