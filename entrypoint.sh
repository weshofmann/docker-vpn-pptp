#!/bin/sh

set -x
set -e

cat <<EOF > /etc/ppp/chap-secrets
# Secrets for authentication using PAP
# client    server      secret      acceptable local IP addresses
$VPN_USERNAME   *   $VPN_PASSWORD   *
EOF

cat /etc/ppp/chap-secrets

# enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# configure firewall
iptables -t nat -A POSTROUTING -s 10.99.99.0/24 ! -d 10.99.99.0/24 -j MASQUERADE
iptables -A FORWARD -s 10.99.99.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
iptables -A INPUT -i ppp0 -j ACCEPT
iptables -A OUTPUT -o ppp0 -j ACCEPT
iptables -A FORWARD -i ppp0 -j ACCEPT
iptables -A FORWARD -o ppp0 -j ACCEPT

exec "$@"
