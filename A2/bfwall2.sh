#!/bin/bash

# User Configuration

# The IP of the DHCP server - may or may not need ?
DHCP_SERVER="192.168.0.1"

# --  ADAPTORS  --
# The adaptor for the internal network
IINTERNAL_NET="eth1"
# The adaptor for the exernal network
IEXTERNAL_NET="eth0"
# The loopback adaptor
ILOOPBACK="lo"

# --  IP ADDRESSES  --

INTERNAL_IP="192.168.10.2"

GATEWAY_INTERNAL_IP="192.168.10.1"
GATEWAY_IP="192.168.0.187"

# -- SERVICES/PORTS  --

# Valid SSH Client Side Ports
VALID_SSH_PORTS="1020:65535"

VALID_TCP_DEST_PORTS="80,443"
VALID_TCP_SRC_PORTS="80,443"


VALID_UDP_SRC_PORTS=""
VALID_UDP_DEST_PORTS=""

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

#masquerade data going out the external card
$IPTABLES --table nat --append POSTROUTING --out-interface $IEXTERNAL_NET -j MASQUERADE
#route all data to the internal system
$IPTABLES --table nat -A PREROUTING -i $IEXTERNAL_NET -j DNAT --to-destination $INTERNAL_IP
#$IPTABLES --append FORWARD --in-interface $IINTERNAL_NET -j ACCEPT  



echo "Default Policies Set"
# Enable Loopback for safekeeping
$IPTABLES -A INPUT -i $ILOOPBACK -j ACCEPT
$IPTABLES -A OUTPUT -o $ILOOPBACK -j ACCEPT

echo "Loopback Policy Complete"

# Do not accept any packets with a source address from the outside matching your internal network
#$IPTABLES -A FORWARD -i $IEXTERNAL_NET -o $IINTERNAL_NET -s $INTERNAL_IP -j DROP

# Inbound/Outbound TCP packets on allowed ports

$IPTABLES -A FORWARD -p tcp ! --syn -m multiport --source-port $VALID_TCP_DEST_PORTS -m multiport --destination-port $UNPRIV_PORTS -j ACCEPT
$IPTABLES -A FORWARD -p tcp -m multiport --source-port $UNPRIV_PORTS -m multiport --destination-port $VALID_TCP_DEST_PORTS -j ACCEPT



#$IPTABLES -A FORWARD -p tcp -m multiport --destination-port $VALID_TCP_PORTS -j ACCEPT

# Inbound/Outbound UDP packets on allowed ports
#$IPTABLES -A FORWARD -p udp -m multiport --source-port $VALID_UDP_SRC_PORTS -m multiport --destination-port $VALID_UDP_DEST_PORTS -j ACCEPT
#$IPTABLES -A FORWARD -p udp -m multiport --destination-port $VALID_UDP_PORTS -j ACCEPT

# Inbound/Outbound ICMP packets based on type numbers
#for i in $VALID_ICMP_NUMBERS
#do
#    $IPTABLES -A FORWARD -p icmp --icmp-type $i -j ACCEPT
#done

# You must ensure the you reject those connections that are coming the “wrong” way (i.e., inbound SYN packets to high ports).

# Accept fragments.

#Accept all TCP packets that belong to an existing connection (on allowed ports).

#Drop all TCP packets with the SYN and FIN bit set.


#Do not allow Telnet packets at all.
#$IPTABLES -A FORWARD -p tcp --source-port 23 -j DROP
#$IPTABLES -A FORWARD -p tcp --destination-port 23 -j DROP

#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515.

#For FTP and SSH services, set control connections to "Minimum Delay" and FTP data to "Maximum Throughput".



