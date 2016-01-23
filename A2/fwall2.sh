#!/bin/sh

# User Configuration

# The IP of the DHCP server - may or may not need ?
DHCP_SERVER="192.168.0.1"

# The adaptor for the internal network
IINTERNAL_NET=""
# The adaptor for the exernal network
IEXTERNAL_NET=""
# The loopback adaptor
ILOOPBACK="lo"

IPTABLES="/sbin/iptables"

# The firewall workstation's ip address
IPADDR="192.168.0.101"

# Valid SSH Client Side Ports
SSH_PORTS="1020:65535"

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



