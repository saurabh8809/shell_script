----------------------------------------------------------------------------------------------------

	Installation of nagios server 

----------------------------------------------------------------------------------------------------

Steps to execute the script [ nagios_server_ubuntu.sh ]

1 - First update your ubuntu machine by using below command

	sudo apt-get update -y
	sudo apt-get upgrade -y

2 - Give executable permision to Scripts.

3 - Then run the script nagios_server_ubuntu.sh with sudo privilege and follow the script instruction.

******************************************************************************************************

#
#
#

------------------------------------------------------------------------------------------------------

	Steps to install nrpe and nagios plugins on client machine

------------------------------------------------------------------------------------------------------

# You need to execute the script [ ubuntu_client.sh ] on nagios clinet to which you want to monitor from nagios server

1 - Copy the ubuntu_client.sh file to your client machine

2 - First update your ubuntu machine by using below command

        sudo apt-get update -y
        sudo apt-get upgrade -y

3 - Give executable permision to Scripts.

4 - Then run the script with sudo privilege and follow the script instruction.

******************************************************************************************************

#
#
# 

______________________________________________________________________________________________________

	Steps to add hosts in nagios server

______________________________________________________________________________________________________

# You need to run this script [ add_client_to_nagios_server.sh ]  on nagios server for adding client to nagios server

1 - Give executable permision to add_client_to_nagios_server.sh

2 - Then run the script with sudo privilege and follow the script instruction.

# if your are facing any issue you can contact me on my emain srbhkumar594@gmail.com 
