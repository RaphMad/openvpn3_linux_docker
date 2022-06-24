#!/bin/sh

ip46tables() {
    iptables $@
    ip6tables $@
}

to_dns_hex() {
    IFS=.
    for i in ${1}; do
        # See https://stackoverflow.com/a/17184231/3324111
        echo -n "|${#i}|$i"
    done
}

VPN_IF=tun0
DOCKER_IF=eth0

# Disable all outgoing traffic that is not explicitely allowed.
ip46tables -P OUTPUT DROP

# Allow all outgoing traffic for the VPN interface.
ip46tables -A OUTPUT -o $VPN_IF -j ACCEPT

# Allow loopback communication.
ip46tables -A OUTPUT -o lo -j ACCEPT

# Allow only VPN traffic (udp port 1194) on the docker interface.
ip46tables -A OUTPUT -o $DOCKER_IF -p udp --dport 1194 -j ACCEPT

# Allow established/related traffic.
ip46tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow DNS (tcp/udp port 53) on the docker interface only for looking up the VPN endpoints DNS name.
ip46tables -A OUTPUT -o $DOCKER_IF -p udp --dport 53 -m string --hex-string $(to_dns_hex $VPN_HOST) --algo bm -j ACCEPT
ip46tables -A OUTPUT -o $DOCKER_IF -p tcp --dport 53 -m string --hex-string $(to_dns_hex $VPN_HOST) --algo bm -j ACCEPT

(su openvpn && sleep 10 && openvpn3 session-start --dco ${ENABLE_DCO:-false} --config $VPN_CONFIG &)
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
