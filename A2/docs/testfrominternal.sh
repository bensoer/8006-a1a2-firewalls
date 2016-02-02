#!/bin/bash

GATEWAY_IP="192.168.0.10"
GATEWAY_INTERNAL_IP="192.168.10.1"
INTERNAL_IP="192.168.10.2"
EXTERNAL_IP="192.168.0.14"
DNS_SERVER="8.8.8.8"
LOOPBACK="127.0.0.1"

HPING3="/usr/sbin/hping3"

OPEN_TCP_PORTS=(80 443 53 22 21)
OPEN_UDP_PORTS=(53)

ICMP_TYPES=(0 3 4 8 11 13 14)

#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515.
CLOSED_TCP_PORTS=(32768 32769 32770 32771 32772 32773 32774 32775 137 138 139 111 515)


echo "============================================"
echo " WARNING: RUNNING testfrominternal.sh."
echo " -GATEWAY_IP: $GATEWAY_IP"
echo " -GATWAY_INTERNAL_IP: $GATEWAY_INTERNAL_IP"
echo " -INTERNAL_IP: $INTERNAL_IP"
echo " -EXTERNAL_IP: $EXTERNAL_IP"
echo "============================================"
echo " ** NOW EXECUTING ** "



echo " Executing DNS test"
#DNS_T1
#hping3 192.168.0.1 --udp -s 1035 -p 53 -c 3
SENT=$($HPING3 $DNS_SERVER --udp -s 1035 -p 53 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $DNS_SERVER --udp -s 1035 -p 53 -p 53 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT -ne $RECIEVED ]
	then
		echo "DNS_T1 - PASS"
fi

#DNS_T3
#hping3 192.168.0.1 -p 53 -c 3
SENT=$($HPING3 $DNS_SERVER --udp -p 53 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $DNS_SERVER --udp -s 53 -p 1035 -p 53 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT -ne $RECIEVED ]
	then
		echo "DNS_T1 - PASS"
fi


echo " Executing TCP Traffic Tests. This Will Test test rules in the tcp_traffic chain. See TCP_T5, TCP_T6, TCP_T7 to check any unexpected results"
 TCP TESTS
for PORT in ${OPEN_TCP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP SYN Request to PORT: $PORT Got Through. Port is Open"
	else
		echo "FAIL - TCP SYN Request to PORT: $PORT Did Not Get Through. Port is Closed"
	fi

done

echo " Executing UDP Traffic Tests. This Will Test test rules in the udp_traffic chain. See UDP_T5, UCP_T6 to check any unexpected results"
# UCP TESTS
for PORT in ${OPEN_UDP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP --udp -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_--udp IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
		echo "FAIL - TCP FRAGMENT Request to PORT: $PORT Did Not Get Through. Port is Closed"
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - UDP Request to PORT: $PORT Got Through. Port is Open"
	else
		echo "FAIL - UDP Request to PORT: $PORT Did Not Get Through. This is UDP Though...it has no response"
	fi

done

echo " Executing ICMP Traffic Tests. This Will Test test rules in the icmp_traffic chain. See ICMP_T2, ICMP_T3 to check any unexpected results"
# ICMP TESTS
for PORT in ${ICMP_TYPES[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP --icmp --icmptype $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP --icmp --icmptype $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
        echo "FAIL - ICMP Request of type: $PORT had no response. Only 8 has a response."
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - ICMP Request type: $PORT Got Through."
	else
        echo "FAIL - ICMP Request of type: $PORT had no response. Only 8 has a response."
	fi

done

echo " Executing FRAGMENT Traffic Tests. This Will Test test a rule in the tcp_traffic chain. See FRAG_T1 to check any unexpected results"
# Fragment TESTS

    PORT=80
	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP -k -S -s 1050 -p $PORT -c 3 -f --data 2048 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP -k -S -s 1050 -p $PORT -c 3 -f --data 2048 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
		echo "FAIL - TCP FRAGMENT Request to PORT: $PORT Did Not Get Through. Port is Closed"
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP FRAGMENT Request to PORT: $PORT Got Through. Fragments allowed"
	else
		echo "FAIL - TCP FRAGMENT Request to PORT: $PORT Did Not Get Through. Port is Closed"
	fi

echo " Executing Telnet Traffic Tests. This Will Test test a rule in the telnet_traffic chain. See TELNET_T4 to check any unexpected results"
# Telnet TESTS

    PORT=23
	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP -k -SF -s 23 -p 23 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP -k -SF -s 23 -p 23 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
		echo "FAIL - Telnet Request failed. Telnet is blocked"
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - Telnet Request succeed. Telnet is allowed"
	else
		echo "FAIL - Telnet Request failed. Telnet is blocked"
	fi


echo " Executing IP DIRECTIONAL Traffic Tests. This Will Test test a rule in the tcp_traffic chain. See TCP_T8 to check any unexpected results"
# IP DIRECTIONAL TESTS

    SPOOFED_IP="8.8.8.8"
    PORT=80
	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP -k -S -p $PORT -c 3 --spoof 8.8.8.8 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP -k -S -p $PORT -c 3 --spoof 8.8.8.8 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
		echo "FAIL - TCP FRAGMENT Request from $SPOOFED_IP Did Not Come Back. It's form a spoofed IP it should't come back here"
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP packet Request to PORT Got Through. Backwards IPs allowed... somehow"
	else
		echo "FAIL - TCP FRAGMENT Request from $SPOOFED_IP Did Not Come Back. It's form a spoofed IP it should't come back here"
	fi

echo " Executing Loopback Tests. This Will Test test a rule in the ACCEPT chain. See LO_T1 to check any unexpected results"
# Fragment TESTS

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 127.0.0.1 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 127.0.0.1 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
		echo "FAIL - Loopback failed to return. Loopback blocked"
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - Loopback packets returned."
	else
		echo "FAIL - Loopback failed to return. Loopback blocked"
	fi

echo " Executing SSH Tests. This Will Test test a rule in the SSH chain. See SSH_T1 to check any unexpected results"
# SSH TESTS
	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP -k -S -p 22 -s 1050 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP -k -S -p 22 -s 1050 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
        echo "FAIL - SSH Request had no response."
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - SSH Request type Got Through."
	else
        echo "FAIL - SSH Request had no response."
	fi

echo " Executing FTP Tests. This Will Test test a rule in the FTP chain. See FTP_T1 to check any unexpected results"
# FTP TESTS
	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP -k -S -p 21 -s 1050 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP -k -S -p 21 -s 1050 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
        echo "FAIL - FTP Request had no response."
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - FTP Request type Got Through."
	else
        echo "FAIL - FTP Request had no response."
	fi

echo " Executing TCP Tests. This Will Test test a rule in the TCP chain. See TCP_T9 to check any unexpected results"
# ICMP TESTS
for PORT in ${CLOSED_TCP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $EXTERNAL_IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $EXTERNAL_IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

    if [ -z "$RECIEVED" ]
    then
		echo "FAIL - TCP SYN Request to PORT: $PORT Did Not Get Through. Port is Closed"
	elif [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP SYN Request to PORT: $PORT Got Through. Port is Open"
	else
		echo "FAIL - TCP SYN Request to PORT: $PORT Did Not Get Through. Port is Closed"
	fi

done
