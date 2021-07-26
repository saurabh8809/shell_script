if [[ "${UID}" -eq 0 ]]
then
  echo 'You are root.'
else
  echo 'You are not root please run the script with root privilege.'
  exit 1
fi

read -p 'Enter the password to use for the nagiosadmin account: ' PASSWORD

read -p 'Enter email id for configuration: ' EMAIL

echo "
*************************************************
*                                               *
*          Installing Required Packages         *
*                                               *
*************************************************
"

yum install -y gettext wget net-snmp-utils openssl-devel glibc-common unzip perl epel-release gcc php gd automake autoconf httpd make glibc gd-devel net-snmp
yum install -y perl-Net-SNMP
useradd nagios
usermod -a -G nagios apache

echo "
*************************************************
*                                               *
*    Downloading Nagios Core And Its Plugins    *
*                                               *
*************************************************
"
cd ~

wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.5.tar.gz

tar -zxvf nagios-4.4.5.tar.gz    
 
cd nagios-4.4.5/

echo "
*************************************************
*                                               *
*    Configuring  And Installing Nagios Core    *
*                                               *
*************************************************
"


./configure 
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf
systemctl enable nagios
systemctl enable httpd

htpasswd -c -b /usr/local/nagios/etc/htpasswd.users nagiosadmin ${PASSWORD}
systemctl restart httpd
cd ~
systemctl restart network
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz

tar -xzvf nagios-plugins-2.3.3.tar.gz 

cd nagios-plugins-2.3.3/
./configure
make install

mkdir -p /usr/local/nagios/etc/servers

echo "
*************************************************
*                                               *
*              Installing NRPE			        *
*                                               *
*************************************************
"

cd ~

wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz 

tar -xf nrpe-3.2.1.tar.gz
cd nrpe-3.2.1

./configure

make check_nrpe
make install-plugin

cd ~

echo 'define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}'  >> /usr/local/nagios/etc/objects/commands.cfg


sed -i '51s/^#//' /usr/local/nagios/etc/nagios.cfg
sed -i "s/nagios@localhost/${EMAIL}/" /usr/local/nagios/etc/objects/contacts.cfg

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

touch /usr/local/nagios/user-passwd
echo "USER NAME = nagiosadmin" >> /usr/local/nagios/user-passwd
echo "PASSWORD = ${PASSWORD}" >> /usr/local/nagios/user-passwd
echo "  "
echo " "
systemctl restart nagios
echo "We have stored your username and password in /usr/local/nagios/user-passwd file"
echo "  "
echo " "
echo "
*****************************************
*                                       *
*      Installation Completed           *
*                                       *
*****************************************
"


