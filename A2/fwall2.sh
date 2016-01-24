#!/bin/sh

# User Configuration

# The IP of the DHCP server - may or may not need ?
DHCP_SERVER="192.168.0.1"

# --  ADAPTORS  --
# The adaptor for the internal network
IINTERNAL_NET=""
# The adaptor for the exernal network
IEXTERNAL_NET=""
# The loopback adaptor
ILOOPBACK="lo"

# --  IP ADDRESSES  --

INTERNAL_IP=""
GATEWAY_IP=""

# -- SERVICES/PORTS  --

# Valid SSH Client Side Ports
VALID_SSH_PORTS="1020:65535"
VALID_TCP_PORTS=""
VALID_UDP_PORTS=""
# use bash array syntax: ( 8 12 16 )
VALID_ICMP_NUMBERS=()

# --  IPTABLES  --

IPTABLES="/sbin/iptables"

echo "User Defined Variables Defined"


# Implementation Section

BROADCAST_SRC="0.0.0.0"
BROADCAST_DEST="255.255.255.255"

PRIV_PORTS="0:1023"
UNPRIV_PORTS="1024:65535"

echo "Firewall Variables Defined"

# Flush out anything before this firewall
$IPTABLES -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F

$IPTABLES -X
$IPTABLES -t nat -X
$IPTABLES -t mangle -X

echo "Flush Of IPTABLES Complete"

# Set the default policy
$IPTABLES --policy INPUT DROP
$IPTABLES --policy OUTPUT DROP
$IPTABLES --policy FORWARD DROP

#$IPTABLES -t nat --policy PREROUTING DROP
#$IPTABLES -t nat --policy OUTPUT DROP
#$IPTABLES -t nat --policy POSTROUTING DROP

# -- No mangle needed, this intercepts data, dropping here will drop it in between
#$IPTABLES -t mangle --policy PREROUTING DROP
#$IPTABLES -t mangle --policy OUTPUT DROP

echo "Defaulkt Policies Set"
# Enable Loopback for safekeeping
$IPTABLES -A INPUT -i $ILOOPBACK -j ACCEPT
$IPTABLES -A OUTPUT -o $ILOOPBACK -j ACCEPT

echo "Loopback Policy Complete"

# Do not accept any packets with a source address from the outside matching your internal network
$IPTABLES -A FORWARD -i $IEXTERNAL_NET -o $INTERNAL_IP -s $INTERNAL_IP -j DROP

# Inbound/Outbound TCP packets on allowed ports
$IPTABLES -A FORWARD -p tcp -m multiport --source-port $VALID_TCP_PORTS -j ACCEPT
$IPTABLES -A FORWARD -p tcp -m multiport --destination-port $VALID_TCP_PORTS -j ACCEPT

# Inbound/Outbound UDP packets on allowed ports
$IPTABLES -A FORWARD -p udp -m multiport --source-port $VALID_UDP_PORTS -j ACCEPT
$IPTABLES -A FORWARD -p udp -m multiport --destination-port $VALID_UDP_PORTS -j ACCEPT

# Inbound/Outbound ICMP packets based on type numbers
for i in $VALID_ICMP_NUMBERS
do
    $IPTABLES -A FORWARD -p icmp --icmp-type $i -j ACCEPT
done





