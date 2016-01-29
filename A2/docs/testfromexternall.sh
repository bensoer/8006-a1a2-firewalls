#!/bin/bash

GATEWAY_IP="192.168.0.179"
GATEWAY_INTERNAL_IP="192.168.10.1"
INTERNAL_IP="192.168.10.2"

HPING3="/usr/sbin/hping3"

echo "============================================"
echo " WARNING: RUNNING testfromexternal.sh."
echo " -GATEWAY_IP: $GATEWAY_INTERNAL_IP"
echo " -GATWAY_INTERNAL_IP: $GATEWAY_INTERNAL_IP"
echo " -INTERNAL_IP: $INTERNAL_IP"
echo "============================================"
echo " ** NOW EXECUTING ** "

$HPING3 $GATEWAY_IP -S -p 80 -c 3 |& awk '{print $5}'