#!/usr/bin/env python3
"""Wrapper for pactl."""

from argparse import ArgumentParser
from subprocess import check_output, run
from typing import Optional

SINK_INPUT = "Sink Input #"
SOURCE = "Source #"
SINK = "Sink #"
APP_NAME = "application.name = "
ALSA_NAME = "alsa.card_name = "
GET_VOL = "Volume: "
SET_VOL = "Set volume in 0-65536 / %% / dB"


class PactlWrapper:
    def __init__(self):
        self.args = self.get_parser().parse_args()

    def get_parser(self):
        parser = ArgumentParser(description=__doc__)
        parser.set_defaults(func=self.main)
        subparsers = parser.add_subparsers()
        parser_app = subparsers.add_parser("application", aliases=["app"])
        parser_mic = subparsers.add_parser("microphone", aliases=["mic"])
        parser_spk = subparsers.add_parser("speaker", aliases=["spk"])
        parser_app.set_defaults(func=self.application)
        parser_mic.set_defaults(func=self.microphone)
        parser_spk.set_defaults(func=self.speaker)
        parser_app.add_argument("name", help="application name")
        parser_mic.add_argument("name", help="microphone name")
        parser_app.add_argument("set_vol", nargs="?", help=SET_VOL)
        parser_mic.add_argument("set_vol", nargs="?", help=SET_VOL)
        parser_spk.add_argument("set_vol", nargs="?", help=SET_VOL)
        return parser

    def run(self):
        """Entrypoint."""
        self.args.func(**vars(self.args))

    def main(self, **kwargs):
        """TODO."""
        print("not yet implemented")

    def lines(self, cmd: [str]):
        """Helper to get text lines out of a command."""
        return check_output(cmd, text=True).split("\n")

    def application(self, name: str, set_vol: Optional[str] = None, **kwargs):
        """Applications are "sink inputs"."""
        for line in self.lines(["pactl", "list", "sink-inputs"]):
            if line.startswith(SINK_INPUT):
                sink = int(line.removeprefix(SINK_INPUT))
            line = line.strip()
            if line.startswith(GET_VOL):
                get_vol = line.removeprefix(GET_VOL)
            if line.startswith(APP_NAME) and name in line:
                name = line.removeprefix(APP_NAME)
                break
        else:
            raise ValueError(f"'{name}' not found in sink-inputs")
        if set_vol:
            run(["pactl", "set-sink-input-volume", str(sink), set_vol])
            print(f"application {name} volume set to: {set_vol}")
        else:
            print(f"application {name} has volume: {get_vol}")

    def microphone(self, name: str, set_vol: Optional[str] = None, **kwargs):
        """Microphones are "sources"."""
        for line in self.lines(["pactl", "list", "sources"]):
            if line.startswith(SOURCE):
                source = int(line.removeprefix(SOURCE))
            line = line.strip()
            if line.startswith(GET_VOL):
                get_vol = line.removeprefix(GET_VOL)
            if line.startswith(ALSA_NAME) and name in line:
                name = line.removeprefix(ALSA_NAME)
                break
        else:
            raise ValueError(f"'{name}' not found in sources")
        if set_vol:
            run(["pactl", "set-source-volume", str(source), set_vol])
            print(f"microphone {name} volume set to: {set_vol}")
        else:
            print(f"microphone {name} has volume: {get_vol}")

    def speaker(self, set_vol: Optional[str] = None, **kwargs):
        """Speakers are "sinks"."""
        # Let's assume there is only one.
        for line in self.lines(["pactl", "list", "sinks"]):
            if line.startswith(SINK):
                sink = int(line.removeprefix(SINK))
            line = line.strip()
            if line.startswith(GET_VOL):
                get_vol = line.removeprefix(GET_VOL)
            if line.startswith(ALSA_NAME):
                name = line.removeprefix(ALSA_NAME)
        if set_vol:
            run(["pactl", "set-sink-volume", str(sink), set_vol])
            print(f"speaker {name} volume set to: {set_vol}")
        else:
            print(f"speaker {name} has volume: {get_vol}")


if __name__ == "__main__":
    PactlWrapper().run()