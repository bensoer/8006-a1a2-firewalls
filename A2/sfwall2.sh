#!/bin/bash

clear

##User defnied section
IPT='/sbin/iptables'    #iptables command exact path
NetworkInside="eth1"
NetworkOutside="eth0"

$FirewallIP="192.168.10.1"
$InternalNetworkIPs="192.168.10.2"

HighPorts=1024:65535 #These are the higher ports for src web traffic
LowPorts=1:1023 #These are the higher ports for src web traffic

$BanPorts="22"




$IPT -F
$IPT -X
$IPT  -t  nat  -F
$IPT  -t  nat  -X
$IPT  -t  mangle  -F
$IPT  -t  mangle  -X

$IPT  --policy  INPUT       DROP
$IPT  --policy  OUTPUT      DROP
$IPT  --policy  FORWARD     DROP

#$IPT --append INPUT  -i $Loopback -j DROP #TODO should this be drop
#$IPT --append OUTPUT -o $Loopback -j DROP #TODO should this be drop

#Creates the chains based on network interface
$IPT --new-chain ExternNetwork
$IPT --new-chain InternNetwork
$IPT --append FORWARD -d $FirewallIP -j DROP
$IPT --append FORWARD -i NetworkOutside -j ExternNetwork
$IPT --append FORWARD -i NetworkInside  -j InternNetwork

$IPT --append NetworkOutside -s $InternalNetworkIPs -j DROP #This will drop any traffic comming in form outside the network with an internal ip

#Creates the chains to seperate the traffic based on protocol
$IPT --new-chain TCPTrafficExtern
$IPT --new-chain UDPTrafficExtern
$IPT --new-chain ICMPTrafficExtern
$IPT --append ExternNetwork -p TCP -j TCPTrafficExtern
$IPT --append ExternNetwork -p UDP -j UDPTrafficExtern
$IPT --append ExternNetwork -p ICMP -j ICMPTrafficExtern

$IPT --new-chain TCPTrafficIntern
$IPT --new-chain UDPTrafficIntern
$IPT --new-chain ICMPTrafficIntern
$IPT --append InternNetwork -p TCP -j TCPTrafficIntern
$IPT --append InternNetwork -p UDP -j UDPTrafficIntern
$IPT --append InternNetwork -p ICMP -j ICMPTrafficIntern

#This will drop all traffic on the ban ports such at tellnet 22
$IPT --append TCPTrafficExtern --sport $BanPorts -j DROP
$IPT --append TCPTrafficExtern --dport $BanPorts -j DROP
$IPT --append TCPTrafficIntern --sport $BanPorts -j DROP
$IPT --append TCPTrafficIntern --dport $BanPorts -j DROP
$IPT --append UDPTrafficExtern --sport $BanPorts -j DROP
$IPT --append UDPTrafficExtern --dport $BanPorts -j DROP
$IPT --append UDPTrafficIntern --sport $BanPorts -j DROP
$IPT --append UDPTrafficIntern --dport $BanPorts -j DROP



#TODO drop all packets with SYN and FIN set
#TODO DROP all packets where SYN is comming the wrong way (i.e., inbound SYN packets to high ports)
#TODO Accept all TCP packets that belong to an existing connection (on allowed ports)
#TODO Block all external traffic directed to ports 32768 –32775, 137 –139, TCP ports 111 and 515
#TODO For FTP and SSH services, set control connections to "Minimum Delay" and FTP data to "Maximum Throughput"

#These are the accounting for all dropped packets
$IPT --append ExternNetwork -j DROP
$IPT --append InternNetwork -j DROP
$IPT --append TCPTrafficExtern -j DROP
$IPT --append UDPTrafficExtern -j DROP
$IPT --append ICMPTrafficExtern -j DROP
$IPT --append TCPTrafficIntern -j DROP
$IPT --append UDPTrafficIntern -j DROP
$IPT --append ICMPTrafficIntern -j DROP
