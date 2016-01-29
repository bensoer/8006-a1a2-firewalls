

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