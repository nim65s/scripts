#!/usr/bin/env python

"""
Pandoc filter to convert markdown's "%[caption](my_video.mp4)"
to html5 & latex video tags

Same syntax as https://github.com/rekado/parkdown#extensions
"""

from pandocfilters import RawBlock, toJSONFilter
FORMATS = {
        'latex': ['beamer'],
        'html': ['revealjs', 'html', 'html5'],
        }
TEMPLATES = {
        'latex': r"""\begin{figure}[htbp]
        \centering
        \movie[width=8cm,height=4.5cm]{}{%s}
        \caption{%s}
        \end{figure}""",
        'html': r"""<figure>
        <video controls>
        <source src='%s' type='video/mp4'>
        Your player does not support the video tag
        </video>
        <figcaption>%s</figcaption>
        </figure>""",
        }
PERCENT = {
        't': 'Str',
        'c': '%',
        }


def media(key, value, format, meta):
    if key == 'Para' and value[0] == PERCENT and value[1]['t'] == 'Link':
        title, src = value[1]['c'][1][0]['c'], value[1]['c'][2][0]
        for fmt_name, fmt_values in FORMATS.items():
            if format in fmt_values:
                return [RawBlock(fmt_name, TEMPLATES[fmt_name] % (src, title))]

if __name__ == "__main__":
    toJSONFilter(media)
