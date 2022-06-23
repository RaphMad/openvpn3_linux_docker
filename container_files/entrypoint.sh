#!/bin/sh

iptables -P OUTPUT DROP
iptables -A OUTPUT -o tun0 -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --match multiport --dports 1194,53 -j ACCEPT

ip6tables -P OUTPUT DROP
ip6tables -A OUTPUT -o tun0 -j ACCEPT
ip6tables -A OUTPUT -o eth0 -p udp --match multiport --dports 1194,53 -j ACCEPT

(su openvpn; sleep 10; openvpn3 session-start --dco ${ENABLE_DCO:-false} --config $VPN_CONFIG &)
exec /usr/bin/dbus-daemon --nofork --nopidfile --system
