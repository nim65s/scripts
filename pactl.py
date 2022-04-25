#!/usr/bin/env python3
"""Wrapper for pactl."""

from argparse import ArgumentParser
from subprocess import check_output, run
from typing import Optional, List, Tuple
from os import environ
from logging import getLogger, basicConfig


LOGGER = getLogger("pactlpy")
ADC_MAX = 2838
SINK_INPUT = "Sink Input #"
SOURCE = "Source #"
SINK = "Sink #"
APP_NAME = "application.name = "
ALSA_NAME = "alsa.card_name = "
GET_VOL = "Volume: "
SET_VOL = "Set volume in 0-65536 / %% / dB"


class PactlWrapper:
    def __init__(self) -> None:
        self.parser = self.get_parser()
        self.args = self.parser.parse_args()
        self.single = self.args.entry.__name__ != "mqtt"
        basicConfig(level=(20 if self.single else 30) - 10 * self.args.verbose)

    def get_parser(self) -> ArgumentParser:
        parser = ArgumentParser(description=__doc__)
        parser.add_argument(
            "-v",
            "--verbose",
            action="count",
            default=0,
            help="increment verbosity level",
        )
        parser.set_defaults(entry=self.help)
        subparsers = parser.add_subparsers()
        parser_app = subparsers.add_parser("application", aliases=["app"])
        parser_mic = subparsers.add_parser("microphone", aliases=["mic"])
        parser_spk = subparsers.add_parser("speaker", aliases=["spk"])
        parser_mqtt = subparsers.add_parser("mqtt")
        parser_app.set_defaults(entry=self.application)
        parser_mic.set_defaults(entry=self.microphone)
        parser_spk.set_defaults(entry=self.speaker)
        parser_mqtt.set_defaults(entry=self.mqtt)
        parser_app.add_argument("name", help="application name")
        parser_mic.add_argument("name", help="microphone name")
        parser_app.add_argument("set_vol", nargs="?", help=SET_VOL)
        parser_mic.add_argument("set_vol", nargs="?", help=SET_VOL)
        parser_spk.add_argument("set_vol", nargs="?", help=SET_VOL)
        parser_mqtt.add_argument(
            "-u",
            "--mqtt-username",
            default=environ.get("MQTT_USERNAME", None),
            help="MQTT client username. Environment variable: MQTT_USERNAME",
        )
        parser_mqtt.add_argument(
            "-p",
            "--mqtt-password",
            default=environ.get("MQTT_PASSWORD", None),
            help="MQTT client password. Environment variable: MQTT_PASSWORD",
        )
        parser_mqtt.add_argument(
            "-H",
            "--mqtt-host",
            default=environ.get("MQTT_HOST", "mqtt"),
            help="MQTT server host. Default: mqtt. Environment variable: MQTT_HOST",
        )
        parser_mqtt.add_argument(
            "-P",
            "--mqtt-port",
            default=int(environ.get("MQTT_PORT", 1883)),
            type=int,
            help="MQTT server port. Default: 1883. Environment variable: MQTT_PORT",
        )
        return parser

    def run(self) -> None:
        """Entrypoint."""
        self.args.entry(**vars(self.args))

    def help(self, **kwargs) -> None:
        """Print help and exit."""
        self.parser.print_help()

    def mqtt(self, **kwargs) -> None:
        """Listen to MQTT request."""
        import paho.mqtt.client as mqtt  # type: ignore

        SCALE = 65536 / ADC_MAX

        def on_connect(client, userdata, flags, rc):
            client.subscribe("/pactlpy/#")

        def on_message(client, userdata, msg):
            chan = int(msg.topic.split("/")[-1])
            if chan == "log":
                LOGGER.info(msg.payload.decode())
            else:
                val = str(int(int(msg.payload.decode()) * SCALE))
                LOGGER.debug(f"mqtt message on {chan=}: {val=}")
                if chan == 0:
                    self.application("snapclient", val)
                elif chan == 1:
                    self.application("Firefox", val)
                elif chan == 2:
                    self.application("VLC", val)
                elif chan == 3:
                    self.microphone("BIRD", val)
                elif chan == 4:
                    self.speaker(val)

        LOGGER.info("connecting...")
        client = mqtt.Client()
        client.username_pw_set(self.args.mqtt_username, self.args.mqtt_password)
        client.on_connect = on_connect
        client.on_message = on_message
        client.connect(self.args.mqtt_host, self.args.mqtt_port, 60)
        LOGGER.info("connected")
        try:
            client.loop_forever()
        except KeyboardInterrupt:
            LOGGER.info("stop")
            client.disconnect()

    def lines(self, cmd: str) -> List[str]:
        """Helper to get text lines out of a command."""
        return check_output(cmd.split(), text=True).split("\n")

    def get_sink_inputs(self, name: str) -> Tuple[List[int], Optional[str]]:
        """Parse list of sink-inputs, looking for a particular name."""
        sinks, vol = [], None
        for line in self.lines("pactl list sink-inputs"):
            if line.startswith(SINK_INPUT):
                sink = int(line.removeprefix(SINK_INPUT))
            line = line.strip()
            if line.startswith(GET_VOL):
                get_vol = line.removeprefix(GET_VOL)
            if line.startswith(APP_NAME):
                if name in line.removeprefix(APP_NAME).strip('"'):
                    sinks.append(sink)
                    vol = get_vol
        return sinks, vol

    def application(self, name: str, set_vol: Optional[str] = None, **kwargs) -> None:
        """Applications are "sink inputs"."""
        sinks, vol = self.get_sink_inputs(name)
        if vol is None:
            err = f"'{name}' not found in sink-inputs"
            if self.single:
                raise ValueError(err)
            LOGGER.warning(err)
            return
        if set_vol is not None:
            for sink in sinks:
                run(["pactl", "set-sink-input-volume", str(sink), set_vol])
                LOGGER.info(f"application {name} ({sink}) volume set to: {set_vol}")
        else:
            LOGGER.info(f"application {name} ({sinks}) has volume: {vol}")

    def get_sources(self, name: str = None) -> Tuple[List[int], Optional[str]]:
        """Parse list of sources, looking for a particular name."""
        sources, vol = [], None
        for line in self.lines("pactl list sources"):
            if line.startswith(SOURCE):
                source = int(line.removeprefix(SOURCE))
            line = line.strip()
            if line.startswith(GET_VOL):
                get_vol = line.removeprefix(GET_VOL)
            if line.startswith(ALSA_NAME):
                if name in line.removeprefix(ALSA_NAME).strip('"'):
                    sources.append(source)
                    vol = get_vol
        return sources, vol

    def microphone(self, name: str, set_vol: Optional[str] = None, **kwargs) -> None:
        """Microphones are "sources"."""
        sources, vol = self.get_sources(name)
        if vol is None:
            err = f"'{name}' not found in sources"
            if self.single:
                raise ValueError(err)
            LOGGER.warning(err)
            return
        if set_vol is not None:
            for source in sources:
                run(["pactl", "set-source-volume", str(source), set_vol])
                LOGGER.info(f"microphone {name} ({source}) volume set to: {set_vol}")
        else:
            LOGGER.info(f"microphone {name} ({sources}) has volume: {vol}")

    def speaker(self, set_vol: Optional[str] = None, **kwargs) -> None:
        """Speakers are "sinks"."""
        # Let's assume there is only one.
        for line in self.lines("pactl list sinks"):
            if line.startswith(SINK):
                sink = int(line.removeprefix(SINK))
            line = line.strip()
            if line.startswith(GET_VOL):
                get_vol = line.removeprefix(GET_VOL)
            if line.startswith(ALSA_NAME):
                name = line.removeprefix(ALSA_NAME)
        if set_vol:
            run(["pactl", "set-sink-volume", str(sink), set_vol])
            LOGGER.info(f"speaker {name} ({sink}) volume set to: {set_vol}")
        else:
            LOGGER.info(f"speaker {name} ({sink}) has volume: {get_vol}")


if __name__ == "__main__":
    PactlWrapper().run()
