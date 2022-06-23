#!/bin/sh

mkdir -p /tmp/lib/openvpn3/configs/

/usr/bin/dbus-daemon --fork --nopidfile --system
openvpn3 session-start --dco true --config /netherlands.ovpn

exec runuser -u openvpn sleep infinity
