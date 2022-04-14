#!/usr/bin/env python

from argparse import ArgumentParser
from datetime import datetime
from json import loads
from time import sleep
from subprocess import CalledProcessError, check_output, DEVNULL

parser = ArgumentParser()
parser.add_argument("-s", "--single", action="store_true")


def cmd(cmd: str) -> str:
    try:
        return check_output(cmd.split(), stderr=DEVNULL, text=True).strip()
    except CalledProcessError:
        return red("x")


def red(val: str) -> str:
    return f"<span foreground='red'>{val}</span>"


def single():
    ips = [
        addr["local"]
        for inet in loads(cmd("ip -j a"))
        for addr in inet["addr_info"]
        if addr["local"] not in ["127.0.0.1", "::1"]
    ]
    try:
        net = cmd("iwctl device list")
        net = next(l.strip() for l in net.split("\n") if "station" in l).split()[0]
        net = cmd(f"iwctl station {net} show")
        net = next(l.strip() for l in net.split("\n") if "Connected" in l).split()[-1]
    except StopIteration:
        net = ""
    dfs = [
        f"{part['mountpoint']} {part['fsuse%']}"
        for part in loads(cmd("lsblk -Jo mountpoint,fsuse%"))["blockdevices"]
        if part["mountpoint"] not in [None, "[SWAP]", "/boot", "/boot/efi"]
    ]
    dat = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    try:
        bat = cmd("acpi -b").split(",")[1].strip()
        bat = red(bat) if int(bat[:-1]) <= 30 else bat
    except IndexError:
        bat = ""
    if "yes" in cmd("pactl get-sink-mute @DEFAULT_SINK@"):
        vol = red("mute")
    else:
        try:
            vol = cmd("pactl get-sink-volume @DEFAULT_SINK@").split()[4].strip()
        except IndexError:
            vol = ""
    bri = cmd("light")
    avg = cmd("uptime").split(":")[-1].strip()
    mem = cmd("free -h --si").split()[9]
    mem = red(mem) if float(mem[:-1].replace(",", ".")) < 2 else mem
    ips = " ".join(ips)
    dfs = " ".join(dfs)
    rfk = red("RFKill") if "yes" in cmd("rfkill list") else ""
    print(
        " | ".join(d for d in (rfk, net, ips, dfs, mem, avg, bri, vol, bat, dat) if d)
    )


if __name__ == "__main__":
    args = parser.parse_args()
    if args.single:
        single()
    else:
        while True:
            single()
            sleep(5)
