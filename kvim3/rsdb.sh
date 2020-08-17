#!/system/bin/sh
iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

ndc tether dns set dns1 8.8.8.8
ndc ipfwd enable forwarding
