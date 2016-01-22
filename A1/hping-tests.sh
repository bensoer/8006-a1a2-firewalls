

# Test DNS Can Get Through
hping3 192.168.0.101 -udp -s 53 -p 1024 -c 3
hping3 192.168.0.103 -s 53 -p 1024 -c 3

#Test Loopback
hping3 127.0.0.1 -c 3 #should return RA as there is no service behind localhost

#Test DNS
hping3 192.168.0.1 -udp -p 53 -c 3 #DNS_T1
hping3 192.168.0.101 -udp -s 53 -p 1035 #DNS_T2
hping3 192.168.0.1 -p 53 -c 3 #DNS_T3
hping3 192.168.0.101 -s 53 -p 1035 #DNS_T4

# Test SSH Can Get Through
# -- SSH with SYN
hping3 192.168.0.101 -S -s 22 -p 22 -c 3  #should fail due to invalid source port
hping3 192.168.0.101 -S -s 1035 -p 22 -c 3 #should recieve SA

hping3 192.168.0.101 -S -s 22 -p 1035 -c 3 #SSH_T1 - SHOULD FAIL
hping3 192.168.0.101 -SA -s 22 -p 1035 -c 3 #SSH_T1 - SHOULD RETURN RA
hping3 192.168.0.101 -S -s 1035 -p 22 -c 3 #SSH_T2

# -- SSH without SYN
hping3 192.168.0.101 -s -p 22 -c 3 #should recieve SA

# Test HTTP Can Get Through
hping3 192.168.0.101 -S -p 80 -c 3 #should recieve SA. RA if service is not enabled
hping3 192.168.0.101 -S -p 443 -c 3 #should recieve SA. RA if service is not enabled

hping3 192.168.0.101 -S -p 80 -s 80 -c 3 #should fail due to explicitly dropped packet as source port is priveleged




