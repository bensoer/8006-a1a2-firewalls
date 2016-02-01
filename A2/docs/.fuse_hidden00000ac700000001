#!/bin/bash

GATEWAY_IP="192.168.0.179"
GATEWAY_INTERNAL_IP="192.168.10.1"
INTERNAL_IP="192.168.10.2"

HPING3="/usr/sbin/hping3"

OPEN_TCP_PORTS=(80 443 53 22 21)
OPEN_UDP_PORTS=(53)

ICMP_TYPES=(0 3 4 8 11 13 14)

#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515.
CLOSED_TCP_PORTS=(32768 32769 32770 32771 32772 32773 32774 32775 137 138 139 111 515)


echo "============================================"
echo " WARNING: RUNNING testfromexternal.sh."
echo " -GATEWAY_IP: $GATEWAY_IP"
echo " -GATWAY_INTERNAL_IP: $GATEWAY_INTERNAL_IP"
echo " -INTERNAL_IP: $INTERNAL_IP"
echo "============================================"
echo " ** NOW EXECUTING ** "

# TCP SYN TESTS
for PORT in ${OPEN_TCP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP SYN Request to PORT: $PORT Got Through"
	else
		echo "FAIL - TCP SYN Request to PORT: $PORT Did Not Get Through"
	fi

done

# TCP SYNACK TESTS
for PORT in ${OPEN_TCP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k -SA -s $PORT -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k -SA -s $PORT -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP SYNACK Request to PORT: $PORT Got Through"
	else
		echo "FAIL - TCP SYNACK Request to PORT: $PORT Did Not Get Through - Stateful Routing Is Working"
	fi

done

# TCP SAME PORT TESTS
for PORT in ${OPEN_TCP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k -SA -s $PORT -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k -SA -s $PORT -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP SAMEPORT Request to PORT: $PORT Got Through"
	else
		echo "FAIL - TCP SAMEPORT Request to PORT: $PORT Did Not Get Through"
	fi

done

#TCP HIGH SYN PORT TESTS (BACKWARDS SYN CALL)
for PORT in ${OPEN_TCP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k -S -s $PORT -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k -S -s $PORT -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP HIGHSYN Request to PORT: $PORT Got Through"
	else
		echo "FAIL - TCP HIGHSYN Request to PORT: $PORT Did Not Get Through - Drop of Backwards Calls is Working"
	fi

done

#TCP SYNFIN TESTS
for PORT in ${OPEN_TCP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k -SF -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k -SF -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP SYNFIN Request to PORT: $PORT Got Through"
	else
		echo "FAIL - TCP SYNFIN Request to PORT: $PORT Did Not Get Through - Explcite SYNFIN DROP is Working"
	fi

done

SENT=""
RECIEVED=""

#TCP HIGH SRC HIGH DEST SYN PORT TESTS (ODD SYN CALL)
SENT=$($HPING3 $GATEWAY_IP -k -S -s 3206 -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $GATEWAY_IP -k -S -s 3206 -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

echo $SENT
echo $RECIEVED

if [ $SENT -eq $RECIEVED ]
then
	echo "PASS - TCP HIGHDESTSRCSYN Request Got Through"
else
	echo "FAIL - TCP HIGHDESTSRCSYN Request Did Not Get Through - Drop of Obscure Calls is Working"
fi



#UDP SYN TESTS
for PORT in ${OPEN_UDP_PORTS[@]}
do

	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k --udp -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k --udp -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - UDP Request to PORT: $PORT Got Through"
	else
		echo "FAIL - UDP Request to PORT: $PORT Did Not Get Through. This is UDP Though...it has no response"
	fi

done

#ICMP TESTS
for TYPE in ${ICMP_TYPES[@]}
do

	SENT="PREVAL2"
	RECIEVED=""

	echo "$SENT - $RECIEVED"

	SENT=$($HPING3 $GATEWAY_IP -k --icmp --icmptype $TYPE -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k --icmp --icmptype $TYPE -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ "$SENT" == "$RECIEVED" ]
	then
		echo "PASS - ICMP Request Type: $TYPE Got Through"
	else
		echo "FAIL - ICMP Request Type: $TYPE Did Not Get Through"
	fi


done


SENT=""
RECIEVED=""

#DNS_T2
#hping3 192.168.0.101 --udp -s 53 -p 1035 -c 3 
SENT=$($HPING3 $GATEWAY_IP -k --udp -s 53 -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $GATEWAY_IP -k --udp -s 53 -p 1035 -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT -ne $RECIEVED ]
	then
		echo "DNS_T2 - PASS - Got Through"
	else
		echo "DNS_T2 - FAIL - Could Not Get Through"
fi

SENT=""
RECIEVED=""

#DNS_T4
#hping3 192.168.0.101 -s 53 -p 1035 -c 3
SENT=$($HPING3 $GATEWAY_IP -k -s 53 -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $GATEWAY_IP -k -s 53 -p 1035 -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT -ne $RECIEVED ]
	then
		echo "DNS_T4 - PASS - Got Through"
	else
		echo "DNS_T4 - FAIL - Could Not Get Through"
fi

SENT=""
RECIEVED=""

#TELNET_T1
SENT=$($HPING3 $GATEWAY_IP -k -S -p 23 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $GATEWAY_IP -k -S -p 23 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT -ne $RECIEVED ]
	then
		echo "PASS - TELNET_T1 - Could Not Get Through"
	else
		echo "FAIL - TELNET_T1 - Could Get Through"
fi

SENT=""
RECIEVED=""

#TELNET_T2
SENT=$($HPING3 $GATEWAY_IP -k -SA -s 23 -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $GATEWAY_IP -SA -k -s 23 -p 1035 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT -ne $RECIEVED ]
	then
		echo "PASS - TELNET_T2 - Could Not Get Through"
	else
		echo "FAIL - TELNET_T3 - Could Get Through"
fi

SENT=""
RECIEVED=""

#TELNET_T3
SENT=$($HPING3 $GATEWAY_IP -k -SA -s 23 -p 23 -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
RECIEVED=$($HPING3 $GATEWAY_IP -SA -k -s 23 -p 23 -c 3 2>&1| grep "3 packets" | awk '{print $4 }')

if [ $SENT -ne $RECIEVED ]
	then
		echo "PASS - TELNET_T3 - Could Not Get Through"
	else
		echo "FAIL - TELNET_T3 - Could Get Through"
fi

#TCP EXTERNAL TRAFFIC BLOCK ON SPECIFIC PORTS
#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515.
for PORT in ${CLOSED_TCP_PORTS[@]}
do

	SENT="PREVAL2"
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k -S -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -S -k -p $PORT-c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ "$SENT" == "$RECIEVED" ]
	then
		echo "PASS - TCP SYN REQUEST to PORT: $PORT Got Through"
	else
		echo "FAIL - TCP SYN REQUEST to PORT: $PORT Did Not Get Through - Explicit Block Working"
	fi


done

#UDP EXTERNAL TRAFFIC BLOCK ON SPECIFIC PORTS
#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515.
for PORT in ${CLOSED_TCP_PORTS[@]}
do

	SENT="PREVAL2"
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k --udp -p $PORT -c 3 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP --udp -k -p $PORT-c 3 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ "$SENT" == "$RECIEVED" ]
	then
		echo "PASS - UDP SYN REQUEST to PORT: $PORT Got Through"
	else
		echo "FAIL - UDP SYN REQUEST to PORT: $PORT Did Not Get Through - Explicit Block Working"
	fi


done

#FRAGMENTS TEST
for PORT in ${OPEN_TCP_PORTS[@]}
do
	SENT=""
	RECIEVED=""

	SENT=$($HPING3 $GATEWAY_IP -k --frag -S -p $PORT -c 3 --data 2000 2>&1| grep "3 packets" | awk '{print $1 }')
	RECIEVED=$($HPING3 $GATEWAY_IP -k --frag -S -p $PORT -c 3 --data 2000 2>&1| grep "3 packets" | awk '{print $4 }')

	echo $SENT
	echo $RECIEVED

	if [ $SENT -eq $RECIEVED ]
	then
		echo "PASS - TCP FRAGMENT Request to PORT: $PORT Got Through"
	else
		echo "FAIL - TCP FRAGMENT Request to PORT: $PORT Did Not Get Through"
	fi

done
