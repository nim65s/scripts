#!/usr/bin/env python

"""
Pandoc filter to convert markdown 's "%[caption](my_video.mp4)"
to html5 & latex video tags
"""

from pandocfilters import toJSONFilter, RawBlock

WEB = ['revealjs', 'html', 'html5']
TEX = ['beamer', 'latex']

TEMPLATE_WEB = r'''
<video controls>
  <source src="%s" type="video/mp4">
  Your browser does not support mp4 in html5's video tag.
</video>
'''

TEMPLATE_TEX = r'\movie[width=8cm,height=4.5cm]{}{%s}'


def media(key, value, format, meta):
    if key == 'Para' and value[0] == {'t': 'Str', 'c': '%'} and value[1]['t'] == 'Link':
        src = value[1]['c'][2][0]
        if src.endswith('.mp4'):
            if format in WEB:
                return [RawBlock('html', TEMPLATE_WEB % src)]
            elif format in TEX:
                return [RawBlock('latex', TEMPLATE_TEX % src)]

if __name__ == "__main__":
    toJSONFilter(media)
