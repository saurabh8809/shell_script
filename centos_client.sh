# use this script to setup nagios client on Red Hat based linux distribution

yum install -y gcc glibc glibc-common openssl openssl-devel perl 
yum install wget -y
useradd nagios

cd ~

cd ~
wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz

tar -xzvf nagios-plugins-2.3.3.tar.gz 

cd nagios-plugins-2.3.3/
./configure
make install

cd ~

wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz 

tar -xf nrpe-3.2.1.tar.gz
cd nrpe-3.2.1

./configure

make check_nrpe
make install-plugin
make all
make install
make install-config
make install-init

cd ~

firewall-cmd --permanent --add-port=5666/tcp
firewall-cmd --reload


# saving all the ip addresses
ip_addresses=$(hostname -I)

# splitting them by space
ip_addresses=(${ip_addresses//" "/ })

# Print each ip address line by line
echo "LIST OF IP ADDRESSES

"
i=0
for ip in "${ip_addresses[@]}";
do
  printf "$i - $ip\n"
  i=$((i+1))
done

echo " "

echo 'Select the ip by which you want to connect to nagios server by entering it respective list  number : '
read -e OPTIONS

echo " "
echo "You have select ${ip_addresses[${OPTIONS}]} for connection to your nagios server

"
echo "If you want to change the ip Please abort the script by using ctrl + c and again start the script"

sed -i '312s/^#//' /usr/local/nagios/etc/nrpe.cfg
sed -i '313s/^#//' /usr/local/nagios/etc/nrpe.cfg
sed -i '314s/^#//' /usr/local/nagios/etc/nrpe.cfg
sed -i '315s/^#//' /usr/local/nagios/etc/nrpe.cfg
sed -i '316s/^#//' /usr/local/nagios/etc/nrpe.cfg
sed -i '317s/^#//' /usr/local/nagios/etc/nrpe.cfg
sed -i 's/allowed_hosts=/#&/g' /usr/local/nagios/etc/nrpe.cfg
sed -i '61s/^/#/' /usr/local/nagios/etc/nrpe.cfg

sed -i "62a server_address=${ip_addresses[${OPTIONS}]}"  /usr/local/nagios/etc/nrpe.cfg

#sed -i "62a server_address=192.168.5.51"  /usr/local/nagios/etc/nrpe.cfg

echo 'Enter the IP address of Nagios Server: '
read -e SERVER_IP 

sed -i "107a allowed_hosts=127.0.0.1,::1,${SERVER_IP}" /usr/local/nagios/etc/nrpe.cfg

#sed -i "107a allowed_hosts=127.0.0.1,::1,192.168.5.50" /usr/local/nagios/etc/nrpe.cfg

abc=`df -h / | sed -n '2p' | awk '{print $1}'`

sed -i "s|/dev/hda1|${abc}|" /usr/local/nagios/etc/nrpe.cfg

sudo systemctl start nrpe.service

sudo systemctl status nrpe.service
