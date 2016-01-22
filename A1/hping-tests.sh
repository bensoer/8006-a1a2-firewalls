

# Test DNS Can Get Through
hping3 192.168.0.101 -udp -s 53 -p 1024 -c 3
hping3 192.168.0.103 -s 53 -p 1024 -c 3



# Test SSH Can Get Through
# -- SSH with SYN
hping3 192.168.0.101 -S -s 22 -p 22 -c 3  #should fail due to invalid source port
hping3 192.168.0.101 -S -s 1035 -p 22 -c 3 #should recieve SA

# -- SSH without SYN
hping3 192.168.0.101 -s -p 22 -c 3 #should recieve SA

# Test HTTP Can Get Through
hping3 192.168.0.101 -S -p 80 -c 3 #should recieve SA. RA if service is not enabled
hping3 192.168.0.101 -S -p 443 -c 3 #should recieve SA. RA if service is not enabled

hping3 192.168.0.101 -S -p 80 -s 80 -c 3 #should fail due to explicitly dropped packet as source port is priveleged




