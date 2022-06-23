#!/bin/sh

(su openvpn; sleep 10; openvpn3 session-start --dco true --config /netherlands.ovpn) &
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
