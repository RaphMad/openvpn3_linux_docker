#!/bin/sh

ip46tables () {
    iptables $@
    ip6tables $@
}

DOCKER_IF=eth0
VPN_IF=tun0

# Disable all outgoing traffic that is not explicitely allowed.
ip46tables -P OUTPUT DROP

# Allow all outgoing traffic for the VPN tunnel interface.
ip46tables -A OUTPUT -o $VPN_IF -j ACCEPT

# Allow only VPN traffic (udp port 1194) on the actual interface.
ip46tables -A OUTPUT -o $DOCKER_IF -p udp --dport 1194 -j ACCEPT

# Allow DNS (udp port 53) on all interfaces (docker provides a local DNS on the loopback interface).
ip46tables -A OUTPUT -p udp --dport 53 -j ACCEPT
ip46tables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow established/related traffic.
ip46tables -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

(su openvpn; sleep 10; openvpn3 session-start --dco ${ENABLE_DCO:-false} --config $VPN_CONFIG &)
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
