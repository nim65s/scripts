#!/usr/bin/env python3

import argparse
import re
from datetime import timedelta
from os import chmod
from os.path import dirname, exists, join
from shutil import copy
from subprocess import PIPE, run

from slugify import slugify


def valid_time(option):
    match = re.match(r'(?P<H>\d\d)?:?(?P<M>\d\d):(?P<S>\d\d)(?P<F>.\d+)?', option)
    if not match:
        raise argparse.ArgumentTypeError(f'Time should be specified as [HH:]MM:SS[.f], got {option}')
    r = match.groupdict(0)
    return str(timedelta(seconds=int(r['S']) + float(r['F']) + 60 * (int(r['M']) + 60 * int(r['H']))))


def valid_file(option):
    if not exists(option):
        raise argparse.ArgumentTypeError(f'This should be an existing file: {option}')
    return str(option)


parser = argparse.ArgumentParser(description='Create a Gepetto Video')
parser.add_argument('rush', type=valid_file, help="filename of the rush")
parser.add_argument('author', type=str, help="speaker's name")
parser.add_argument('title', type=str, help="talk's title")
parser.add_argument('--image', type=valid_file, help="title image", default='title.png')
parser.add_argument('-ss', '--start-time', default='00:00', type=valid_time, help="start of the video")
parser.add_argument('-to', '--end-time', default='00:00', type=valid_time, help="end of the video")
parser.add_argument('-n', default=0, type=int, help="number of the video in a playlist (0 for no playlist)")
parser.add_argument('-fs', default=60, type=int, help="font size")
parser.add_argument('--no-magic', action='store_true', default=False)
parser.add_argument('-c', '--crop', action='store_true', default=False, help='Crop the speaker only from the video')


if __name__ == '__main__':
    options = parser.parse_args()

    # get cmd that cuts the rush
    cut_rush_cmd = f'ffmpeg -i {options.rush}'
    if options.start_time != '0:00:00':
        cut_rush_cmd += f' -ss {options.start_time}'
    if options.end_time != '0:00:00':
        cut_rush_cmd += f' -to {options.end_time}'
    author, title = slugify(options.author), slugify(options.title)
    filename = f'{author}_{title}'
    if options.n:
        filename = f'{options.n:02}_{filename}'
    directory = dirname(options.rush)
    path = join(directory, filename)

    with open(f'{path}.sh', 'w') as f:
        print('#!/bin/bash', file=f)
        print('set +x', file=f)
        print('set +e', file=f)
        print(f'{cut_rush_cmd} -c copy {path}_cutted.mp4', file=f)
        if options.crop:
            print(f'ffmpeg -i {path}_cutted.mp4 -filter:v "crop=296:176:0:90" -strict -2 -c:a copy {path}_cropped.mp4',
                  file=f)
        else:
            print(f'mv {path}_cutted.mp4 {path}_cropped.mp4', file=f)

    # get title frame
    if options.no_magic:
        copy(options.image, f'{path}_title.png')
    else:
        from wand.display import display  # noqa
        from wand.drawing import Drawing  # noqa
        from wand.image import Image  # noqa

        with Image(filename=join(directory, options.image)) as img:
            with Drawing() as draw:
                draw.font_size = options.fs
                draw.text_alignment = 'center'
                title = options.title.replace('^', '\n')
                draw.text(int(img.width/2), int(img.height / 2), f'{options.author}:\n{title}')
                draw(img)
            img.save(filename=f'{path}_title.png')

    # convert title frame to title video
    for line in run(['ffmpeg', '-i', options.rush], stderr=PIPE).stderr.decode().split('\n'):
        if 'Stream' in line and 'Video' in line:
            video_parameters = [s.strip() for s in line.split(',')]
            break
    else:
        raise TypeError(f'The file {options.rush} has not been successfully parsed by ffmpeg')
    cv = 'libx264'  # if 'h264' in video_parameters[0]. otherwise… I don't know :P
    fps, fmt = (video_parameters[i].split()[0] for i in (4, 1))
    with open(f'{path}.txt', 'w') as f:
        print(f'file {filename}_title.mp4', file=f)
        print(f'file {filename}_cropped.mp4', file=f)
    with open(f'{path}.sh', 'a') as f:
        print(f'ffmpeg -loop 1 -i {path}_title.png -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 '
              f'-shortest -strict -2 -c:v {cv} -t 5 -vf fps={fps},format={fmt} -map 0:v -map 1:a {path}_title.mp4',
              file=f)
        print(f'ffmpeg -f concat -i {path}.txt -c copy {path}.mp4', file=f)

    chmod(f'{path}.sh', 0o755)
    print(f'you should now run `./{path}.sh`')
