

echo "======================="
echo "     Firewall Test     "
echo "======================="
echo "Where Is This Test Script Being Executed From? (Enter Number)"
echo "1) From The Firewall Machine"
echo "2) From The Internal Machine"

read ANSWER returnKey
if [ $ANSWER -eq 1 ]
then
    echo "Now Executing testfromexternal Tests"
    ./testfromexternal.sh
fi
if [ $ANSWER -eq 2 ]
then
    echo "Now Executing testfrominternal Tests"
    ./testfrominternal.sh
fi



comments="

-- NOTES --

Can't automate tests for:
OI_T1
OI_T2

IE_T2

TOS_T1
TOS_T2
TOS_T3
TOS_T4
TOS_T5
TOS_T6
TOS_T7
TOS_T8

We have some automation for this but its not reliable/useful
UDP_T1
UDP_T2
UDP_T3
UDP_T4






"