#!/bin/sh

(su openvpn; sleep 10; openvpn3 session-start --dco true --config $VPN_CONFIG) &
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
