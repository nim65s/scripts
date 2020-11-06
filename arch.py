#!/usr/bin/env python3
"""
My https://github.com/Torxed/archinstall scripts.

pacman -Sy python-pip wget
pip install archinstall
wget https://raw.githubusercontent.com/nim65s/scripts/master/arch.py
"""

import getpass

import archinstall

PACKAGES = [
    'git', 'gvim', 'fish', 'openssh', 'tinc', 'python-pip', 'rofi', 'pass', 'pcsc-tools', 'ccid', 'libusb-compat',
    'dunst', 'msmtp-mta', 'shellcheck', 'dfc', 'ripgrep', 'fd', 'khal', 'khard', 'vdirsyncer', 'todoman', 'ncdu',
    'bat', 'htop', 'tig', 'i3', 'usbutils', 'wget'
]

# Select a harddrive and a disk password
harddrive = archinstall.select_disk(archinstall.all_disks())
hostname = input('Hostname: ')
disk_password = getpass.getpass(prompt='Disk password (won\'t echo): ')
nim_password = getpass.getpass(prompt='Nim password (won\'t echo): ')

archinstall.filter_mirrors_by_region('FR')
archinstall.re_rank_mirrors(5)

with archinstall.Filesystem(harddrive, archinstall.GPT) as fs:
    fs.use_entire_disk('luks2')

    harddrive.partition[0].format('fat32')
    with archinstall.luks2(harddrive.partition[1], 'luksloop', disk_password) as unlocked_device:
        unlocked_device.format('btrfs')

        with archinstall.Installer(unlocked_device, harddrive.partition[0], hostname=hostname) as installation:
            if installation.minimal_installation():
                installation.set_locale('fr_FR')
                installation.set_keyboard_language('fr-bepo')
                installation.set_timezone('Europe/Paris')
                installation.activate_ntp()
                installation.add_bootloader()
                installation.user_create('nim', nim_password, sudo=True)
                installation.add_additional_packages(PACKAGES)
                installation.enable_service('pcscd')
                installation.enable_service('systemd-networkd')
