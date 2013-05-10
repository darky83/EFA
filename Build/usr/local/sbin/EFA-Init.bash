#!/bin/bash
# +--------------------------------------------------------------------+
# EFA-Init
# Version 20130510
# +--------------------------------------------------------------------+
# Copyright (C) 2012~2013  http://www.efa-project.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# +--------------------------------------------------------------------+

# +---------------------------------------------------+
# Lets start
# +---------------------------------------------------+
function FUNCTION-START-CONFIG()
{
  echo "EFA: We will ask you a few questions to setup this system"

  # Ask for the hostname
  echo ""
  echo -n "EFA: What is the hostname of this machine? (Single Word): "
  read HOSTNAME
  hncheck=1
  while [ $hncheck != 0 ]
   do
     if [[ $HOSTNAME =~ ^[-a-zA-Z0-9]{2,256}+$ ]]
      then
        echo "EFA: Thank you the hostname will be set to: $HOSTNAME"
        hncheck=0
      else
        echo "ERROR: The hostname $HOSTNAME seems to be invalid"
        echo "ERROR: please re-enter the hostname"
        echo -n "EFA: What is the hostname of this machine: (single Word): "
        read HOSTNAME
     fi
    done

  # Ask for the domainname
  echo ""
  echo -n "EFA: Please enter the domain name for this machine: "
  read DOMAINNAME
  dncheck=1
  while [ $dncheck != 0 ]
   do
     if [[ $DOMAINNAME =~ ^[-.a-zA-Z0-9]{2,256}+$ ]]
      then
        echo "EFA: Thank you the domain will be set to: $DOMAINNAME"
        dncheck=0
      else
        echo "ERROR: The domain $DOMAINNAME seems to be invalid"
        echo "ERROR: please re-enter the domain"
        echo -n "EFA: Please enter the domain name for this machine: "
        read DOMAINNAME
     fi
    done

  # Ask for admin email adres
  echo ""
  echo "EFA: Please enter the email adres of an admin "
  echo -n "EFA: This user will receive EFA related notifications: "
  read ADMINEMAIL
  adminemailcheck=1
  while [ $adminemailcheck != 0 ]
   do
     if [[ $ADMINEMAIL =~ ^[-_.@Aa-zA-Z0-9]{2,256}+$ ]]
      then
        echo "EFA: Thank you the admin email will be set to: $ADMINEMAIL"
        adminemailcheck=0
      else
        echo "ERROR: The adres $ADMINEMAIL seems to be invalid"
        echo "ERROR: please re-enter the admin email adres"
        echo "EFA: Please enter the email adres of an admin "
        echo -n "EFA: This user will receive EFA related notifications: "
        read ADMINEMAIL
     fi
   done

  # Get the primary interface
  func_interfaces
  echo $interface

  # Get the IP and validate it
  echo ""
  echo -n "EFA: Please enter the IP address: "
  read IPADDRESS
  ipcheck=1
  while [ $ipcheck != 0 ]
   do
    if checkip $IPADDRESS
     then
       echo "EFA: Thank you the IP will be set to $IPADDRESS"
       ipcheck=0
     else
       echo "ERROR: The IP $IPADDRESS seems to be invalid"
       echo "ERROR: Please re-enter the IP"
       echo -n "EFA: Please enter the IP address: "
       read IPADDRESS
    fi
   done

  # get the netmask and validate it
  echo ""
  echo -n "EFA: Please enter the NETMASK: "
  read NETMASK
  nmcheck=1
  while [ $nmcheck != 0 ]
   do
    if checkip $NETMASK
     then
       echo "EFA: Thank you the NETMASK will be set to $NETMASK"
       nmcheck=0
     else
       echo "ERROR: The NETMASK $NETMASK seems to be invalid"
       echo "ERROR: Please re-enter the NETMASK"
       echo -n "EFA: Please enter the NETMASK: "
       read NETMASK
    fi
   done

  # get the gateway and validate it
  echo ""
  echo -n "EFA: Please enter the default gateway address: "
  read GATEWAY
  gwcheck=1
  while [ $gwcheck != 0 ]
   do
    if checkip $GATEWAY
     then
       echo "EFA: Thank you the default gateway will be set to $GATEWAY"
       gwcheck=0
     else
       echo "ERROR: The GATEWAY $GATEWAY seems to be invalid"
       echo "ERROR: Please re-enter the GATEWAY"
       echo -n "EFA: Please enter the default gateway address: "
       read GATEWAY
    fi
   done

  # get the primary DNS and validate it
  echo ""
  echo -n "EFA: Please enter the primary DNS server address: "
  read DNS1
  dns1check=1
  while [ $dns1check != 0 ]
   do
    if checkip $DNS1
     then
       echo "EFA: Thank the the primary DNS will be set to $DNS1"
       dns1check=0
     else
       echo "ERROR: The DNS server $DNS1 seems to be invalid"
       echo "ERROR: Please re-enter the primary DNS"
       echo -n "EFA: Please enter the primary DNS server address: "
       read DNS1
    fi
   done

  # get the secondary DNS and validate it
  echo ""
  echo -n "EFA: Please enter the secondary DNS server address: "
  read DNS2
  dns2check=1
  while [ $dns2check != 0 ]
   do
    if checkip $DNS2
     then
       echo "EFA: Thank you the secondary DNS will be set to $DNS2"
       dns2check=0
     else
       echo "ERROR: The DNS server $DNS2 seems to be invalid"
       echo "ERROR: Please re-enter the secondary DNS"
       echo -n "EFA: Please enter the secondary DNS server address: "
       read DNS2
    fi
   done

  echo " "
  echo "EFA: Thank you, applying settings now:"
  echo " "
  FUNCTION-WRITE-SETTINGS
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Make all modifications
# +---------------------------------------------------+
function FUNCTION-WRITE-SETTINGS()
{

#echo "INTERFACE = $INTERFACE"
#echo "IPADDRESS = $IPADDRESS"
#echo "NETMASK = $NETMASK"
#echo "GATEWAY = $GATEWAY"
#echo "DNS1 = $DNS1"
#echo "DNS2 = $DNS2"
#echo "HOSTNAME = $HOSTNAME"
#echo "DOMAINNAME = $DOMAINNAME"
#echo "ADMINEMAIL = $ADMINEMAIL"

  /etc/init.d/rabbitmq-server stop
  echo "EFA: - Setting new hostname"
  echo $HOSTNAME > /etc/hostname
  echo "$HOSTNAME.$DOMAINNAME" > /etc/mailname
  echo "127.0.0.1               localhost" > /etc/hosts
  echo "$IPADDRESS              $HOSTNAME.$DOMAINNAME   $HOSTNAME" >> /etc/hosts
  echo "" >> /etc/hosts
  echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
  echo "::1     ip6-localhost ip6-loopback" >> /etc/hosts
  echo "fe00::0 ip6-localnet" >> /etc/hosts
  echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
  echo "ff02::1 ip6-allnodes" >> /etc/hosts
  echo "ff02::2 ip6-allrouters" >> /etc/hosts
  /etc/init.d/hostname.sh

  echo "EFA: - Setting DNS Servers"
  echo "nameserver $DNS1" > /etc/resolv.conf
  echo "nameserver $DNS2" >> /etc/resolv.conf

  echo "EFA: - Setting IP settings"
  echo "auto $INTERFACE" > /etc/network/interfaces.d/$INTERFACE
  echo "iface $INTERFACE inet static" >> /etc/network/interfaces.d/$INTERFACE
  echo "        address $IPADDRESS" >> /etc/network/interfaces.d/$INTERFACE
  echo "        netmask $NETMASK" >> /etc/network/interfaces.d/$INTERFACE
  echo "        gateway $GATEWAY" >> /etc/network/interfaces.d/$INTERFACE
  echo "        dns-nameservers $DNS1 $DNS2" >> /etc/network/interfaces.d/$INTERFACE

  /etc/init.d/networking stop
  /etc/init.d/networking start

  echo "EFA: - Setting postfix configuration"
  postconf -e myhostname=$HOSTNAME.$DOMAINNAME
  postconf -e mydestination="$HOSTNAME.$DOMAINNAME, localhost.$DOMAINNAME, localhost"
  echo "root $ADMINEMAIL" > /etc/postfix/virtual
  echo "abuse $ADMINEMAIL" >> /etc/postfix/virtual
  echo "postmaster $ADMINEMAIL" >> /etc/postfix/virtual
  postmap /etc/postfix/virtual

  echo "EFA: - Setting baruwa configuration"
  sed -i "/^DEFAULT_FROM_EMAIL = / c\DEFAULT_FROM_EMAIL = 'postmaster@$DOMAINNAME' " /etc/baruwa/settings.py
  sed -i "/^QUARANTINE_REPORT_HOSTURL = / c\QUARANTINE_REPORT_HOSTURL = 'http://$HOSTNAME.$DOMAINNAME' " /etc/baruwa/settings.py

  echo "EFA: - Configuring razor"
  razor-admin -d -create >> /var/log/razor-setup.log
  razor-admin -register >> /var/log/razor-setup.log

  echo "EFA: - Updating ClamAV"
  freshclam

  clear
  echo "EFA: Lets change the passwords"
  echo "EFA: First we start with the password for the efaadmin user (ssh user):"
  passwd efaadmin
  usermod -a -G sudo efaadmin
  echo "EFA: Thank you."
  echo "EFA: Now the root password:"
  passwd root
  echo "EFA: Thank you"
  echo "EFA: Generating random password for baruwa configurations"
  randompw
  echo "EFA: - Applying random password to configuration items"
  /etc/init.d/rabbitmq-server start
  rabbitmqctl add_user baruwa $PASSWD
  rabbitmqctl add_vhost baruwa
  rabbitmqctl set_permissions -p baruwa baruwa ".*" ".*" ".*"
  rabbitmqctl delete_user guest
  sed -i "/^password =/ c\password = $PASSWD" /etc/postfix/mysql-relay_domains.cf
  sed -i "/^password =/ c\password = $PASSWD" /etc/postfix/mysql-transports.cf
  sed -i "/^password =/ c\password = $PASSWD" /etc/postfix/mysql-relay_recipients.cf
  sed -i "/^password =/ c\password = $PASSWD" /etc/postfix/mysql-global_lists.cf
  sed -i "/^        'PASSWORD': / c\        'PASSWORD': '$PASSWD'," /etc/baruwa/settings.py
  sed -i "/^BROKER_PASSWORD = / c\BROKER_PASSWORD = \"$PASSWD\"" /etc/baruwa/settings.py
  /etc/init.d/mysql start
  echo "UPDATE mysql.user SET Password = PASSWORD('$PASSWD') WHERE User = 'baruwa';" | mysql -u root -p'password' mysql
  echo "FLUSH PRIVILEGES" | mysql -u root -p'password' mysql
  sed -i "/^DB Password = / c\DB Password = $PASSWD" /etc/MailScanner/conf.d/baruwa.conf
  PASSWD=""
  echo "EFA: Generating random password for mysql root"
  randompw
  echo $PASSWD > /etc/mysql/EFA.cnf
  chmod 600 /etc/mysql/EFA.cnf
  mysqladmin -u root -p'password' password $PASSWD
  PASSWD=""
  echo "EFA: - Not displaying the password here."
  echo "EFA: Finaly the user to login to baruwa (superuser)"
  baruwa-admin createsuperuser
  baruwa-admin initconfig

  FUNCTION-END
}
# +---------------------------------------------------+


# +---------------------------------------------------+
# Function to determine the available interfaces.
# +---------------------------------------------------+
func_interfaces(){

nrintf=`cat /proc/net/dev | grep eth | awk {' print $1 '} | sed 's/://g' | wc -l`
interf=`cat /proc/net/dev | grep eth | awk {' print $1 '} | sed 's/://g'`

if [ $nrintf -gt 1 ]
  then
    echo ""
    echo "EFA: You seem to have multiple network interfaces"
    echo "EFA: The interface names on your machine are:"
    for int in $interf
     do
       echo " - $int"
     done

        local choice
        read -p "EFA: Enter the primary interface name: " choice
        choice_check=0
        for int in $interf
         do
          if [ $int == $choice ]
           then
            choice_check=1
           fi
         done

         # Check if the user typed a interface that exists.
         if [ $choice_check -eq 0 ]
          then
            echo "EFA: ERROR, That interface does not exist."
            echo "EFA: Staring over."
            sleep 2
            func_interfaces
            return
          fi

        if [ $choice_check -eq 1 ]
         then
          echo "EFA: Thank you, using $choice as the primary interface"
          INTERFACE=$choice
        fi

  else
    echo "EFA: Your interface seems to be '$interf', using $interf as primary interface"
        INTERFACE=$interf
fi
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Function to test IP addresses
# +---------------------------------------------------+
function checkip()
{
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Function to create a random password
# +---------------------------------------------------+
function randompw()
{
  PASSWD=`tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1`
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# The final thingy's
# +---------------------------------------------------+
function FUNCTION-END()
{
  echo "Generating SSH Host keys"
  dpkg-reconfigure openssh-server

  sed -i "/^First time login: /d" /etc/issue

  echo "Enabling services"
  update-rc.d apache2 enable
  update-rc.d rabbitmq-server enable
  update-rc.d mysql enable
  update-rc.d mailscanner enable
  update-rc.d spamassassin enable
  update-rc.d ssh enable
  update-rc.d clamav-freshclam enable
  update-rc.d postfix enable
  echo "/etc/init.d/baruwa start" > /etc/rc.local
  echo "/etc/init.d/DCC start" >> /etc/rc.local
  echo "exit 0" >> /etc/rc.local

  echo "Removing configure script from root login"
  sed -i "/^\/usr\/local\/sbin\/EFA-Init/d" /root/.bashrc

  touch /etc/EFA-Configured
  echo "ADMINEMAIL:$ADMINEMAIL" > /etc/EFA-Configured
  chmod 600 /etc/EFA-Configured
  echo "All settings applied rebooting now"
  sleep 10
  reboot
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Where to start
# +---------------------------------------------------+
clear
echo ""
echo "-- Welcome to the EFA Initial Configuration --"
echo "--        http://www.efa-project.org        --"
echo ""
if [ ! -e /etc/EFA-Configured ]
 then
   FUNCTION-START-CONFIG
 else
   echo "ERROR: EFA is already configured"
   echo "Please use EFA-Configure"
   exit 0
fi
# EOF