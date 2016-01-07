#!/usr/bin/env python

"""
Pandoc filter to convert markdown 's "%[caption](my_video.mp4)"
to html5 & latex video tags

Same syntax as https://github.com/rekado/parkdown#extensions
"""

from pandocfilters import RawBlock, toJSONFilter

FORMATS = {
        'latex': ['beamer', 'latex'],
        'html': ['revealjs', 'html', 'html5'],
        }
TEMPLATES = {
        'latex': r"\movie[width=8cm,height=4.5cm]{}{%s}",
        'html': r"<video controls><source src='%s' type='video/mp4'></video>",
        }
PERCENT = {
        't': 'Str',
        'c': '%',
        }


def media(key, value, format, meta):
    if key == 'Para' and value[0] == PERCENT and value[1]['t'] == 'Link':
        src = value[1]['c'][2][0]
        for fk, fv in FORMATS.items():
            if format in fv:
                return [RawBlock(fk, TEMPLATES[fk] % src)]

if __name__ == "__main__":
    toJSONFilter(media)
