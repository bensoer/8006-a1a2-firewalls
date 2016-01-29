#!/bin/bash

GATEWAY_IP="192.168.0.187"
GATEWAY_INTERNAL_IP="192.168.10.1"
INTERNAL_IP="192.168.10.2"
DNS_SERVER="192.168.0.1"
LOOPBACK="127.0.0.1"


#DNS_T1
#hping3 192.168.0.1 --udp -s 1035 -p 53 -c 3
SENT=$($HPING3 $DNS_SERVER --udp -s 1035 -p 53 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $DNS_SERVER --udp -s 1035 -p 53 -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT ! -eq $RECIEVED ]
	then
		echo "DNS_T1 - PASS"
fi

#DNS_T3
#hping3 192.168.0.1 -p 53 -c 3
SENT=$($HPING3 $DNS_SERVER --udp -p 53 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $DNS_SERVER --udp -s 53 -p 1035 -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT ! -eq $RECIEVED ]
	then
		echo "DNS_T1 - PASS"
fi