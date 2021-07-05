if [[ "${UID}" -eq 0 ]]
then
  echo 'You are root.'
else
  echo 'You are not root please run the script with root privilege.'
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

apt update
sudo apt install -y build-essential apache2 php openssl perl make php-gd libgd-dev libapache2-mod-php libperl-dev libssl-dev daemon wget apache2-utils unzip -y

useradd nagios

usermod -a -G nagios www-data

echo "
*************************************************
*                                               *
*    Downloading Nagios Core And Its Plugins    *
*                                               *
*************************************************
"


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


./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf
a2enmod rewrite cgi
systemctl enable apache2

htpasswd -c -b /usr/local/nagios/etc/htpasswd.users nagiosadmin ${PASSWORD}
systemctl restart apache2
cd ~
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


touch /usr/local/nagios/user-passwd
echo "USER NAME = nagiosadmin" >> /usr/local/nagios/user-passwd
echo "PASSWORD = ${PASSWORD}" >> /usr/local/nagios/user-passwd
echo "  "
echo " "
systemctl start nagios
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
