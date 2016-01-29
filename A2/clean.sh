#!/bin/bash

IPTABLES="/sbin/iptables"

$IPTABLES -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F

$IPTABLES -X
$IPTABLES -t nat -X
$IPTABLES -t mangle -X

$IPTABLES --policy INPUT ACCEPT
$IPTABLES --policy OUTPUT ACCEPT
$IPTABLES --policy FORWARD ACCEPT