#!/usr/bin/env python

from dbus import Boolean, Interface, SystemBus

DEVICE = '00:0C:8A:67:96:90'
DEVICE = DEVICE.replace(':', '_')

bus = SystemBus()

proxy_power = bus.get_object('org.bluez', '/org/bluez/hci0')
interface_power = Interface(proxy_power, dbus_interface='org.freedesktop.DBus.Properties')

if not interface_power.Get('org.bluez.Adapter1', 'Powered'):
    interface_power.Set('org.bluez.Adapter1', 'Powered', True)

proxy_connected = bus.get_object('org.bluez', '/org/bluez/hci0/dev_{}'.format(DEVICE))
interface_connected = Interface(proxy_connected, dbus_interface='org.freedesktop.DBus.Properties')

if not interface_connected.Get('org.bluez.Device1', 'Connected'):
    interface_connect = Interface(proxy_connected, dbus_interface='org.bluez.Device1')
    interface_connect.Connect()
