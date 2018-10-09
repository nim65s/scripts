#!/usr/bin/env python
"""
Try to recover a lost DB:
./fu.py (ag Dette_ajout|cut -d: -f-2) (ag Remboursement_ajout|cut -d: -f-2)
"""

import sys
from email.parser import Parser
from html.parser import HTMLParser


class HTMLMailParser(HTMLParser):
    """
    Parse an html mail, where important data are key/values in dt/dd
    """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.mail_data = {}
        self.key = False

    def handle_starttag(self, tag, attrs):
        if tag == 'dt':
            self.key = True
        elif tag != 'dd':
            self.key = False

    def handle_data(self, data):
        if isinstance(self.key, str):
            self.mail_data[self.key] += data.strip()
        elif self.key:
            self.key = data
            self.mail_data[self.key] = ''


if __name__ == '__main__':
    MAIL_PARSER = Parser()

    for filename in sys.argv[1:]:
        with open(filename) as fp:
            msg = MAIL_PARSER.parse(fp)
        if 'majo@saurel.me' not in msg['From']:
            continue

        html_parser = HTMLMailParser()
        html_part = next(part for part in msg.walk() if part.get_content_type() == 'text/html')
        html_parser.feed(html_part.get_payload())
        print(html_parser.mail_data)
