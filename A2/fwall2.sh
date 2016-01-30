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

# valid tcp connections to internal
VALID_TCP_INBOUND_PORTS="80,443,53,22,21"
# valid tcp connections from internal
VALID_TCP_OUTBOUND_PORTS="80,443,53,22,21"

#valid udp connections to internal
VALID_UDP_OUTBOUND_PORTS="53"
#valid udp connections from internal
VALID_UDP_INBOUND_PORTS="53"

# Set to 1 to explicitly deny telnet port 23 from communicating through the firewall server
NOTELNET=1
# Set to 1 to explicitly drop any packets with a SYN and FIN flags enabled
DROPSYNFIN=1
# Set to 1 to explicitly drop packets from the EXPLICIT_INVALID_TCP_PORTS and EXPLICIT_INVALID_UDP_PORTS list
PORTBLOCK=1
EXPLICIT_INVALID_TCP_PORTS="32768:32775,137:139,111,515"
EXPLICIT_INVALID_UDP_PORTS="32768:32775,137:139"

FTP_DATA_PORTS="20"

# use bash array syntax: ( 8 12 16 )
VALID_ICMP_NUMBERS=(8 0)

echo "User Defined Variables Defined"

# Implementation Section

# --  IPTABLES  --

IPTABLES="/sbin/iptables"

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

# Do not accept any packets with a source address from the outside matching your internal network
$IPTABLES -A PREROUTING -i $IEXTERNAL_NET -s $INTERNAL_IP -j DROP #OI_T1
$IPTABLES -A PREROUTING -i $IEXTERNAL_NET -s $GATEWAY_INTERNAL_IP -j DROP #OI_T2

#masquerade data going out the external card
$IPTABLES --table nat --append POSTROUTING --out-interface $IEXTERNAL_NET -j MASQUERADE
#route all data to the internal system
$IPTABLES --table nat -A PREROUTING -i $IEXTERNAL_NET -j DNAT --to-destination $INTERNAL_IP
echo "> NAT Connections Configured"
echo "Default Policies Set"


#For FTP and SSH services, set control connections to "Minimum Delay" and FTP data to "Maximum Throughput".
$IPTABLES --table mangle -A PREROUTING -p tcp -i $IEXTERNAL_NET --destination-port 22 -j TOS --set-tos minimize-delay #TOS_T1
$IPTABLES --table mangle -A POSTROUTING -p tcp -o $IEXTERNAL_NET --destination-port 22 -j TOS --set-tos minimize-delay #TOS_T2
$IPTABLES --table mangle -A PREROUTING -p tcp -i $IEXTERNAL_NET --source-port 22 -j TOS --set-tos minimize-delay #TOS_T3
$IPTABLES --table mangle -A POSTROUTING -p tcp -o $IEXTERNAL_NET --source-port 22 -j TOS --set-tos minimize-delay #TOS_T4

$IPTABLES --table mangle -A PREROUTING -p tcp -i $IEXTERNAL_NET -m multiport --destination-ports $FTP_DATA_PORTS -j TOS --set-tos maximize-throughput #TOS_T5
$IPTABLES --table mangle -A POSTROUTING -p tcp -o $IEXTERNAL_NET -m multiport --destination-ports $FTP_DATA_PORTS -j TOS --set-tos maximize-throughput #TOS_T6
$IPTABLES --table mangle -A PREROUTING -p tcp -i $IEXTERNAL_NET -m multiport --source-ports $FTP_DATA_PORTS -j TOS --set-tos maximize-throughput #TOS_T7
$IPTABLES --table mangle -A POSTROUTING -p tcp -o $IEXTERNAL_NET -m multiport --source-ports $FTP_DATA_PORTS -j TOS --set-tos maximize-throughput #TOS_T8

echo "TOS Rules Configured"

# Enable Loopback for safekeeping
$IPTABLES -A INPUT -i $ILOOPBACK -j ACCEPT
$IPTABLES -A OUTPUT -o $ILOOPBACK -j ACCEPT

echo "Loopback Policy Complete"

$IPTABLES -N is_new_and_established
$IPTABLES -A is_new_and_established -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT #NAE_T1
$IPTABLES -A is_new_and_established -p udp -m state --state NEW,ESTABLISHED -j ACCEPT #NAE_T2

echo "Is New And Established Chain Created"

$IPTABLES -N is_established
$IPTABLES -A is_established -p tcp -m state --state ESTABLISHED -j ACCEPT #IE_T1
$IPTABLES -A is_established -p udp -m state --state ESTABLISHED -j ACCEPT #IE_T2

echo "Is Established Chain Created"


# -- EXPLICIT DENIALS --



echo "Explcit Denial of External Traffic Matching Internal Traffic IP's"


echo "Checking Whether to Block SYN or FIN"
#Drop all TCP packets with the SYN and FIN bit set.
if [ $DROPSYNFIN -eq 1 ]
then
    echo "Blocking SYN and FIN Packets"
    $IPTABLES -A FORWARD -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP #SYNFIN_T1
fi

echo "Checking Whether to Block Telnet Packets"
#Do not allow Telnet packets at all.
if [ $NOTELNET -eq 1 ]
then
    echo "Blocking Telnet Packets"
    $IPTABLES -A FORWARD -p tcp --source-port 23 -j DROP #TELNET_T1
    $IPTABLES -A FORWARD -p tcp --destination-port 23 -j DROP #TELNET_T2
fi

echo "Checking Whether to Explicitly Block Ports"
#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515.
if [ $PORTBLOCK -eq 1 ]
then
    echo "Blocking Explicit Ports"
    $IPTABLES -A FORWARD -p tcp -i $IEXTERNAL_NET -m multiport --destination-ports $EXPLICIT_INVALID_TCP_PORTS -j DROP #EXPDR_T1
    $IPTABLES -A FORWARD -p udp -i $IEXTERNAL_NET -m multiport --destination-ports $EXPLICIT_INVALID_UDP_PORTS -j DROP # EXPDR_T2
fi


# -- TCP --

# Inbound/Outbound TCP packets on allowed ports
# Accept all TCP packets that belong to an existing connection (on allowed ports).

$IPTABLES -N tcp_traffic

#OUTBOUND
if [ "$VALID_TCP_OUTBOUND_PORTS" != "" ]
then
    $IPTABLES -A tcp_traffic -p tcp -i $IINTERNAL_NET -m multiport --source-ports $UNPRIV_PORTS -m multiport --destination-ports $VALID_TCP_OUTBOUND_PORTS -j is_new_and_established #TCP_T1
    $IPTABLES -A tcp_traffic -p tcp -i $IEXTERNAL_NET -m multiport --source-ports $VALID_TCP_OUTBOUND_PORTS -m multiport --destination-ports $UNPRIV_PORTS -j is_established #TCP_T2
fi
#INBOUND
if [ "$VALID_TCP_INBOUND_PORTS" != "" ]
then
    $IPTABLES -A tcp_traffic -p tcp -i $IEXTERNAL_NET -m multiport --source-ports $UNPRIV_PORTS -m multiport --destination-ports $VALID_TCP_INBOUND_PORTS -j is_new_and_established #TCP_T3
    $IPTABLES -A tcp_traffic -p tcp -i $IINTERNAL_NET -m multiport --source-ports $VALID_TCP_INBOUND_PORTS -m multiport --destination-ports $UNPRIV_PORTS -j is_established #TCP_T4
fi


echo "TCP Traffic Chain Created"


$IPTABLES -A FORWARD -p tcp -j tcp_traffic

echo "TCP Rules Configured"

# -- UDP --


# Inbound/Outbound UDP packets on allowed ports

$IPTABLES -N udp_traffic

#OUTBOUND
if [ "$VALID_UDP_OUTBOUND_PORTS" != "" ]
then
    $IPTABLES -A udp_traffic -p udp -i $IINTERNAL_NET -m multiport --source-ports $UNPRIV_PORTS -m multiport --destination-ports $VALID_UDP_OUTBOUND_PORTS -j is_new_and_established #UDP_T1
    $IPTABLES -A udp_traffic -p udp -i $IEXTERNAL_NET -m multiport --source-ports $VALID_UDP_OUTBOUND_PORTS -m multiport --destination-ports $UNPRIV_PORTS -j is_established #UDP_T2
fi
#INBOUND
if [ "$VALID_UDP_INBOUND_PORTS" != "" ]
then
    $IPTABLES -A udp_traffic -p udp -i $IEXTERNAL_NET -m multiport --source-ports $UNPRIV_PORTS -m multiport --destination-ports $VALID_UDP_INBOUND_PORTS -j is_new_and_established #UDP_T3
    $IPTABLES -A udp_traffic -p udp -i $IINTERNAL_NET -m multiport --source-ports $VALID_UDP_INBOUND_PORTS -m multiport --destination-ports $UNPRIV_PORTS -j is_established #UDP_T4
fi


echo "UDP Traffic Chain Created"

$IPTABLES -A FORWARD -p udp -j udp_traffic

echo "UDP Rules Configured"

$IPTABLES -N icmp_traffic

# Inbound/Outbound ICMP packets based on type numbers
for TYPE in ${VALID_ICMP_NUMBERS[@]}
do
    $IPTABLES -A icmp_traffic -p icmp --icmp-type $TYPE -j ACCEPT #ICMP_T1
done

echo "ICMP Taffic Chain Created"

$IPTABLES -A FORWARD -p icmp -j icmp_traffic

echo "ICMP Rules Configured"

# You must ensure the you reject those connections that are coming the “wrong” way (i.e., inbound SYN packets to high ports).


# Accept fragments
# Don't need rules for fragments. we accept them anyway
#$IPTABLES -A FORWARD -p udp --fragment -j ACCEPT
#$IPTABLES -A FORWARD -p tcp --fragment -j ACCEPT









