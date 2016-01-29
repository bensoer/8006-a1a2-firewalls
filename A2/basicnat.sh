#1/bin/bash

echo "Executing - basicnat.sh"

IPTABLES="/sbin/iptables"
# The adaptor for the internal network
IINTERNAL_NET="eth1"
# The adaptor for the exernal network
IEXTERNAL_NET="eth0"

$IPTABLES --policy INPUT DROP
$IPTABLES --policy OUTPUT DROP
$IPTABLES --policy FORWARD DROP

echo "basinat.sh > Set Default Policies to DROP"

$IPTABLES --table nat -A POSTROUTING --out-interface $IEXTERNAL_NET -j MASQUERADE

$IPTABLES -A FORWARD --in-interface $IEXTERNAL_NET -j ACCEPT
$IPTABLES -A FORWARD --in-interface $IINTERNAL_NET -j ACCEPT

echo "basicnat.sh > Setup basic rules. Everything will be let through the firewall"
