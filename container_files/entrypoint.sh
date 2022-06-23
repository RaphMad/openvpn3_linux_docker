#!/bin/sh

ip46tables () {
    iptables $@
    ip6tables $@
}

# Disable all outgoing traffic that is not explicitely allowed.
ip46tables -P OUTPUT DROP

# Allow all outgoing traffic for the VPN tunnel interface.
ip46tables -A OUTPUT -o tun0 -j ACCEPT

# Allow only VPN traffuc (udp port 1194) on the actual interface.
ip46tables -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT

# Allow DNS (udp port 53) on all interfaces.
ip46tables -A OUTPUT -p udp --dport 53 -j ACCEPT

(su openvpn; sleep 10; openvpn3 session-start --dco ${ENABLE_DCO:-false} --config $VPN_CONFIG &)
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
