#testscriptreadme

The testscript is a modular bash script that will test a number of the automatable core functions of the firewall. To use the testscript
you need to to have setup a firewall machine and have another machine hidden behind it. Traffic should be setup so that the firewall machine
is setup as a gateway to the network beyond it. You can find a useful tutorial here: 
<a href="https://blog.bensoer.com/setup-a-basic-gateway-server-on-linux/">https://blog.bensoer.com/setup-a-basic-gateway-server-on-linux/</a>

To execute the script, make sure `testscript.sh`, `testfromexternal.sh` and `testfrominternal.sh` all have full file permissions. It is possible
that this step does not have to happen, but for best performance it is recommended to give these scripts full 777 file permissions.

Also you will have to load these files onto the size of the firewall you are wanting to test. If you want to test inbound rules for example, you
will need to download and setup these files on a machine outside of the firewall/gateway. If you want to test outbound rules, you will need to
download and setup these scripts on the internal device.

Then from within the folder call `./testscript.sh`. This will present a prompt asking whether these tests are being executed from the internal
machine or from an external machine to the firewall. Enter 1 or 2 to select the appropriate option. The test script will then begin executing the
appropriate tests based on your selection.

Output from these tests will be dumped out to the console. To document the tests to file for future analysis use the stdout redirect `>` and
point it to a file.

Output from the scripts will be minimal if it is expected, and more verbose if a test fails. Each test on failure will prompt you with rule names
and recommendations on where the error may be located. These rule names match to commenting that has been added into the fwall2.sh firewall file.
Each rule name matches to a rule located in the fwall2.sh file. These same rule names can also be traced through the test documentation where you
can view the success case scenarios or any known bugs in the firewall.