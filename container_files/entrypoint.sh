#!/bin/sh

addgroup -g $PGID openvpn
adduser -S -D openvpn -u $PUID -G openvpn

mkdir -p /tmp/lib/openvpn3/configs/

(sleep 10; openvpn3 session-start --dco true --config /netherlands.ovpn) &
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
