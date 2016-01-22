
# NOTES:
# Tests with note 'does go through firewall' do work. configuration with destination is just incorrect. you can confirm the packets go through the firewall
# by looking at the iptables accounting data with the command: iptables -L -n -v -x


# Test DNS Can Get Through
hping3 192.168.0.101 -udp -s 53 -p 1024 -c 3
hping3 192.168.0.103 -s 53 -p 1024 -c 3

#Test Loopback
hping3 127.0.0.1 -c 3 #should return RA as there is no service behind localhost

#Test DNS
hping3 192.168.0.1 --udp -s 1035 -p 53 -c 3 #DNS_T1
hping3 192.168.0.101 --udp -s 53 -p 1035 -c 3 #DNS_T2
hping3 192.168.0.1 -p 53 -c 3 #DNS_T3
hping3 192.168.0.101 -s 53 -p 1035 -c 3 #DNS_T4

# Test SSH Can Get Through
# -- SSH with SYN
hping3 192.168.0.101 -S -s 22 -p 22 -c 3  #should fail due to invalid source port

hping3 192.168.0.101 -S -s 22 -p 1035 -c 3 #SSH_T1 - SHOULD FAIL 
hping3 192.168.0.101 -SA -s 22 -p 1035 -c 3 #SSH_T1 - SHOULD RETURN R

hping3 192.168.0.101 -S -s 1035 -p 22 -c 3 #SSH_T2 - should pass

hping3 192.168.0.186 -S -s 1035 -p 22 #SH_T3 - should pass
hping3 192.168.0.186 -SA -s 22 -p 1035 #SSH_T4 - should pass - does go through firewall

#Test HTTP Can Get Through
hping3  192.168.0.101 -S -s 80 -p 80 -c 3 #HTTP_T1 - should fail
hping3 192.168.0.101 -S -s 443 -p 443 -c 3 #HTTP_T2 - should fail

hping3 192.168.0.101 -SA -s 80 -p 1035 -c 3 #HTTP_T3 - should pass
hping3 192.168.0.101 -SA -s 443 -p 1035 -c 3 #HTTP_T4 - should pass

hping3 192.168.0.101 -S -s 1035 -p 80 -c 3 #HTTP_T5 - should pass
hping3 192.168.0.101 -S -s 1035 -p 443 -c 3 #HTTP_T6 - should pass

hping3 192.168.0.186 -S -s 1035 -p 80 -c 3 #HTTP_T7 - should pass
hping3 192.168.0.186 -S -s 1035 -p 443 -c 3 #HTTP_T8 - should pass

hping3 192.168.0.186 -SA -s 80 -p 1035 -c 3 #HTTP_T9 - should pass - does get through firewall
hping3 192.168.0.186 -SA -s 443 -p 1035 -c 3 #HTTP_T10 - should pass - does get through firewall




