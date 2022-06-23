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

# Allow DNS (tcp/udp port 53) on the docker interface for looking up VPN endpoints DNS name.
ip46tables -A OUTPUT -o $DOCKER_IF -p udp --dport 53 --hex-string $VPN_HOST --algo bm -j ACCEPT
ip46tables -A OUTPUT -o $DOCKER_IF -p tcp --dport 53 --hex-string $VPN_HOST --algo bm -j ACCEPT

# Allow loopback communication.
ip46tables -A OUTPUT -o lo -j ACCEPT

# Allow established/related traffic.
ip46tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

(su openvpn && sleep 10 && openvpn3 session-start --dco ${ENABLE_DCO:-false} --config $VPN_CONFIG &)
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
