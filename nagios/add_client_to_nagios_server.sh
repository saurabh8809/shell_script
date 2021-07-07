# Execute this script after the completion of execution of nagios_server_ubuntu.sh 
# The script will ask some details about for the client please provide that when it ask for that
# This script will register your client in nagios server 

echo "

*********************************************************************

"
  
echo 'Enter the hostname for linux client: '
read -e HOST
echo 'Enter alias for the linux client: '
read -e  ALIAS
echo 'Enter IP Address of the linux client: '
read -e  IP
mkdir -p /usr/local/nagios/etc/servers/

echo '
BY DEFAULT THIS SCRIPT WILL MONITOR CLIENT FOR BELOW SERVICES

PING
Root Partition
Current Users
Total Processes
Current Load
Swap Usage
SSH
HTTP
'

echo "
define host {

    use                     linux-server            
    host_name               ${HOST}
    alias                   ${ALIAS}
    address                 ${IP}
}

###############################################################################
#
# SERVICE DEFINITIONS
#
###############################################################################

# Define a service to "ping" the local machine

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     PING
    check_command           check_ping!100.0,20%!500.0,60%
}



# Define a service to check the disk space of the root partition
# on the local machine.  Warning if < 20% free, critical if
# < 10% free space on partition.

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     Root Partition
    check_command           check_local_disk!20%!10%!/
}



# Define a service to check the number of currently logged in
# users on the local machine.  Warning if > 20 users, critical
# if > 50 users.

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     Current Users
    check_command           check_local_users!20!50
}



# Define a service to check the number of currently running procs
# on the local machine.  Warning if > 250 processes, critical if
# > 400 processes.

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     Total Processes
    check_command           check_local_procs!250!400!RSZDT
}



# Define a service to check the load on the local machine.

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     Current Load
    check_command           check_local_load!5.0,4.0,3.0!10.0,6.0,4.0
}



# Define a service to check the swap usage the local machine.
# Critical if less than 10% of swap is free, warning if less than 20% is free

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     Swap Usage
    check_command           check_local_swap!20%!10%
}



# Define a service to check SSH on the local machine.
# Disable notifications for this service by default, as not all users may have SSH enabled.

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     SSH
    check_command           check_ssh
    notifications_enabled   0
}



# Define a service to check HTTP on the local machine.
# Disable notifications for this service by default, as not all users may have HTTP enabled.

define service {

    use                     local-service           ; Name of service template to use
    host_name               ${HOST}
    service_description     HTTP
    check_command           check_http
    notifications_enabled   0
}" >> /usr/local/nagios/etc/servers/${HOST}.cfg

echo '

Your Client has been added to your server 

Restarting NAGIOS SERVER......

'
sleep 5
systemctl restart nagios

