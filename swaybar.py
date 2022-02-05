#!/usr/bin/env python

from argparse import ArgumentParser
from datetime import datetime
from time import sleep
from subprocess import CalledProcessError, check_output

parser = ArgumentParser()
parser.add_argument("-s", "--single", action="store_true")


def cmd(cmd: str) -> str:
    try:
        return check_output(cmd.split(), text=True).strip()
    except CalledProcessError:
        return red('x')


def red(val: str) -> str:
    return f"<span foreground='red'>{val}</span>"


def single():
    ips = []
    for line in cmd("ip a").split("\n"):
        if line.startswith("    inet ") and "127.0.0.1" not in line:
            ips.append(line.split()[1])
    dfs = []
    for line in cmd("dfc -nt btrfs").split('\n'):
            _, _, pct, _, _, mnt = line.split()
            if float(pct[:-1].replace(',', '.')) > 90:
                pct = red(pct)
            dfs.append(f"{mnt} {pct}")
    dat = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    bat = cmd("acpi -b").split(',')[1].strip()
    bat = red(bat) if int(bat[:-1]) <= 30 else bat
    if 'yes' in cmd("pactl get-sink-mute @DEFAULT_SINK@"):
        vol = red('mute')
    else:
        try:
            vol = cmd("pactl get-sink-volume @DEFAULT_SINK@").split()[4].strip()
        except IndexError:
            vol = ''
    bri = cmd("light")
    avg = cmd("uptime").split(':')[-1].strip()
    mem = cmd("free -h --si").split()[9]
    mem = red(mem) if float(mem[:-1].replace(',', '.')) < 2 else mem
    ips = ' '.join(ips)
    dfs = ' '.join(dfs)
    rfk = red('RFKill') if 'yes' in cmd("rfkill list") else ''
    print(' | '.join(d for d in (rfk, ips, dfs, mem, avg, bri, vol, bat, dat) if d))


if __name__ == "__main__":
    args = parser.parse_args()
    if args.single:
        single()
    else:
        while True:
            single()
            sleep(5)
