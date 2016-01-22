#!/bin/sh

# -- User Defined Variables --
DHCP_SERVER="192.168.0.1"

IINTERNET="eth0"
ILOOPBACK="lo"

IPTABLES="/sbin/iptables"

IPADDR="192.168.0.101"

NAMESERVER="204.194.232.200,204.194.234.200"

# SSH Ports MUST Be written as a list, can't use <start>:<finish> range syntax
SSH_PORTS="1020:65535"

echo "User Defined Variables Defined"

# -- Firewall Variables --
BROADCAST_SRC="0.0.0.0"
BROADCAST_DEST="255.255.255.255"

PRIV_PORTS="0:1023"
UNPRIV_PORTS="1024:65535"

echo "Firewall Varaibles Defined"

# -- Implementation --

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

echo "Loopback Settings Set"

# Enable DNS

# -- For UDP DNS Requests
$IPTABLES -A OUTPUT -o $IINTERNET -p udp -s $IPADDR --sport $UNPRIV_PORTS --dport 53 -j ACCEPT #DNS_T1
$IPTABLES -A INPUT -i $IINTERNET -p udp -d $IPADDR --sport 53 --dport $UNPRIV_PORTS -j ACCEPT #DNS_T2
# -- In case there is error and must use TCP
$IPTABLES -A OUTPUT -o $IINTERNET -p tcp -s $IPADDR --sport $UNPRIV_PORTS --dport 53 -j ACCEPT #DNS_T3
$IPTABLES -A INPUT -i $IINTERNET -p tcp -d $IPADDR --sport 53 --dport $UNPRIV_PORTS -j ACCEPT #DNS_T4

echo "DNS Settings Complete"

# Enable DHCP

# -- Initialization or rebinding
$IPTABLES -A OUTPUT -o $IINTERNET -p udp -s $BROADCAST_SRC -d $BROADCAST_DEST --sport 68 --dport 67 -j ACCEPT
# -- Incoming DHCP offer from other DHCP servers
$IPTABLES -A INPUT -i $IINTERNET -p udp -s $BROADCAST_SRC -d $BROADCAST_DEST --sport 67 --dport 68 -j ACCEPT
# -- Rules for lost lease or reboot for client
$IPTABLES -A OUTPUT -o $IINTERNET -p udp -s $BROADCAST_SRC -d $DHCP_SERVER --sport 68 --dport 67 -j ACCEPT
$IPTABLES -A INPUT -i $IINTERNET -p udp -s $DHCP_SERVER -d $BROADCAST_DEST --sport 67 --dport 68 -j ACCEPT

# -- Variances in DHCP Response
$IPTABLES -A INPUT -i $IINTERNET -p udp -s $DHCP_SERVER --sport 67 --dport 68 -j ACCEPT
# -- -- Lease Renewal
$IPTABLES -A OUTPUT -o $IINTERNET -p udp -s $IPADDR -d $DHCP_SERVER --sport 68 --dport 67 -j ACCEPT
$IPTABLES -A INPUT -i $IINTERNET -p udp -s $DHCP_SERVER -d $IPADDR --sport 67 --dport 68 -j ACCEPT

echo "DHCP Settings Complete"

# Create Chain For SSH Traffic

# -- SSH Input Traffic
$IPTABLES -N ssh_input_traffic

$IPTABLES -A ssh_input_traffic -i $IINTERNET -p tcp ! --syn --sport 22 -d $IPADDR --dport $SSH_PORTS #accounting
$IPTABLES -A ssh_input_traffic -i $IINTERNET -p tcp ! --syn --sport 22 -d $IPADDR --dport $SSH_PORTS -j ACCEPT #SSH_T1

$IPTABLES -A ssh_input_traffic -i $IINTERNET -p tcp -d $IPADDR --sport $SSH_PORTS --dport 22 #accounting
$IPTABLES -A ssh_input_traffic -i $IINTERNET -p tcp -d $IPADDR --sport $SSH_PORTS --dport 22 -j ACCEPT #SSH_T2


echo "SSH Input Chain Created"

$IPTABLES -A INPUT -p tcp --sport 22 -j ssh_input_traffic
$IPTABLES -A INPUT -p tcp --dport 22 -j ssh_input_traffic

echo "SSH Input Settings Complete"


# -- SSH Output Traffic
$IPTABLES -N ssh_output_traffic

$IPTABLES -A ssh_output_traffic -o $IINTERNET -p tcp -s $IPADDR --sport $SSH_PORTS --dport 22 #accounting
$IPTABLES -A ssh_output_traffic -o $IINTERNET -p tcp -s $IPADDR --sport $SSH_PORTS --dport 22 -j ACCEPT #SSH_T3

$IPTABLES -A ssh_output_traffic -o $IINTERNET -p tcp ! --syn -s $IPADDR --sport 22 --dport $SSH_PORTS #accounting
$IPTABLES -A ssh_output_traffic -o $IINTERNET -p tcp ! --syn -s $IPADDR --sport 22 --dport $SSH_PORTS -j ACCEPT #SSH_T4

echo "SSH Output Chain Created"

$IPTABLES -A OUTPUT -p tcp --sport 22 -j ssh_output_traffic
$IPTABLES -A OUTPUT -p tcp --dport 22 -j ssh_output_traffic

echo "SSH Output Settings Complete"

# Create Chain for HTTP Traffic

# -- HTTP Input Traffic
$IPTABLES -N http_input_traffic

# -- -- Explicit drop of Http to dest port 80 from source ports less than 1024
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --dport 80 --sport $PRIV_PORTS #accounting
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --dport 80 --sport $PRIV_PORTS -j DROP #HTTP_T1

$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --dport 443 --sport $PRIV_PORTS #accounting
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --dport 443 --sport $PRIV_PORTS -j DROP #HTTP_T2

# -- -- i think this one here is basicalyt he inverse of the above rule
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp ! --syn --sport 80 -d $IPADDR --dport $UNPRIV_PORTS #accounting
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp ! --syn --sport 80 -d $IPADDR --dport $UNPRIV_PORTS -j ACCEPT #HTTP_T3

$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp ! --syn --sport 443 -d $IPADDR --dport $UNPRIV_PORTS #accounting
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp ! --syn --sport 443 -d $IPADDR --dport $UNPRIV_PORTS -j ACCEPT #HTTP_T4

$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --sport $UNPRIV_PORTS -d $IPADDR --dport 80 #accounting
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --sport $UNPRIV_PORTS -d $IPADDR --dport 80 -j ACCEPT #HTTP_T5

$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --sport $UNPRIV_PORTS -d $IPADDR --dport 443 #accounting
$IPTABLES -A http_input_traffic -i $IINTERNET -p tcp --sport $UNPRIV_PORTS -d $IPADDR --dport 443 -j ACCEPT #HTTP_T6

echo "HTTP Input Chain Created"

$IPTABLES -A INPUT -p tcp -m multiport --source-port 80,443 -j http_input_traffic
$IPTABLES -A INPUT -p tcp -m multiport --destination-port 80,443 -j http_input_traffic

echo "HTTP Input Settings Complete"

# -- HTTP Output Traffic
$IPTABLES -N http_output_traffic

$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp -s $IPADDR --sport $UNPRIV_PORTS --dport 80 #accounting
$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp -s $IPADDR --sport $UNPRIV_PORTS --dport 80 -j ACCEPT #HTTP_T7

$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp -s $IPADDR --sport $UNPRIV_PORTS --dport 443 #accounting
$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp -s $IPADDR --sport $UNPRIV_PORTS --dport 443 -j ACCEPT #HTTP_T8

$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp ! --syn -s $IPADDR --sport 80 --dport $UNPRIV_PORTS #accounting
$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp ! --syn -s $IPADDR --sport 80 --dport $UNPRIV_PORTS -j ACCEPT #HTTP_T9

$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp ! --syn -s $IPADDR --sport 443 --dport $UNPRIV_PORTS #accounting
$IPTABLES -A http_output_traffic -o $IINTERNET -p tcp ! --syn -s $IPADDR --sport 443 --dport $UNPRIV_PORTS -j ACCEPT #HTTP_T10

echo "HTTP Output Chain Created"

$IPTABLES -A OUTPUT -p tcp -m multiport --source-port 80,443 -j http_output_traffic
$IPTABLES -A OUTPUT -p tcp -m multiport --destination-port 80,443 -j http_output_traffic

echo "HTTP Output Settings Complete"
