#!/bin/bash
# +---------------------------------------------------+
# EFA 0.3 update script
# version 20130120
# +--------------------------------------------------------------------+
# Copyright (C) 2012  http://www.efa-project.org
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
# TODO
# - FIX SIGNATURES
# - FIX QUESTION FROM MYSQL CONFIGURATION IN BARUWA UPDATE.
# +---------------------------------------------------+

# +---------------------------------------------------+
# Pause function
# +---------------------------------------------------+
pause(){
	read -p "Press [Enter] key to continue..." fackEnterKey
}
# +---------------------------------------------------+

echo ""
echo "[EFA] WARNING: Did you create a snapshot of your system?" 
echo ""
pause
echo ""
echo "[EFA] Starting update"
# +---------------------------------------------------+

# +---------------------------------------------------+
# Creating backup dirs
mkdir /var/EFA/update/0.3
mkdir /var/EFA/update/0.3/backup
cp /etc/baruwa/settings.py /var/EFA/update/0.3/backup/baruwa-settings.py
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Fixing apache config"

cp /etc/apache2/sites-enabled/baruwa /var/EFA/update/0.3/backup/baruwa-apache-conf-enabled.backup
cp /etc/apache2/sites-available/baruwa /var/EFA/update/0.3/backup/baruwa-apache-conf-available.backup
rm /etc/apache2/sites-enabled/baruwa
rm /etc/apache2/sites-available/baruwa
cp /var/EFA/update/0.3/backup/baruwa-apache-conf-enabled.backup /etc/apache2/sites-available/baruwa
a2ensite baruwa >> /dev/null
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Updating system packages"
echo " "
echo "WARNING: You will get the question if you want to configure mysql TWICE"
echo "WARNING: Please answer these questions with: YES."
echo ""
pause
echo "baruwa baruwa/webserver_type select apache2" | debconf-set-selections
echo "baruwa baruwa/webserver/vhost string localhost.localdomain" | debconf-set-selections
echo "baruwa baruwa/mysql/configure boolean true" | debconf-set-selections
echo "baruwa baruwa/mysql/dbserver string localhost" | debconf-set-selections
echo "baruwa baruwa/mysql/dbadmin string root" | debconf-set-selections
echo "baruwa baruwa/mysql/dbadmpass password password" | debconf-set-selections
echo "baruwa baruwa/mysql/dbuser string baruwa" | debconf-set-selections
echo "baruwa baruwa/mysql/dbpass password" | debconf-set-selections
echo "baruwa baruwa/mysql/dbname string baruwa" | debconf-set-selections
echo "baruwa baruwa/rabbitmq/mqhost string localhost" | debconf-set-selections
echo "baruwa baruwa/rabbitmq/mqvhost string baruwa" | debconf-set-selections
echo "baruwa baruwa/rabbitmq/mquser string baruwa" | debconf-set-selections
echo "baruwa baruwa/rabbitmq/mqpass password password" | debconf-set-selections
echo "baruwa baruwa/django/baruwauser string baruwaadmin" | debconf-set-selections
echo "baruwa baruwa/django/baruwapass password password" | debconf-set-selections
echo "baruwa baruwa/django/baruwaemail string root" | debconf-set-selections
echo "baruwa baruwa/purge boolean true" | debconf-set-selections
echo "baruwa baruwa/mysql/configure boolean true" | debconf-set-selections
apt-get update
apt-get -q -y -o Dpkg::Options::="--force-confnew"  upgrade
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Restoring Baruwa settings"

# Restore original Baruwa database name
BARNAME="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep \'NAME\': | sed 's/.*: //' | tr -d "'" | tr -d ","`"
sed -i "/^        'NAME': / c\        'NAME': '$BARNAME'," /etc/baruwa/settings.py

# Restore original Baruwa database user
BARUSER="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep \'USER\': | sed 's/.*: //' | tr -d "'" | tr -d ","`"
sed -i "/^        'USER': / c\        'USER': '$BARUSER'," /etc/baruwa/settings.py

# Restore original Baruwa database password
BARPASSWORD="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep \'PASSWORD\': | sed 's/.*: //' | tr -d "'" | tr -d ","`"
sed -i "/^        'PASSWORD': / c\        'PASSWORD': '$BARPASSWORD'," /etc/baruwa/settings.py

# Restore original Baruwa database host
BARHOST="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep \'HOST\': | sed 's/.*: //' | tr -d "'" | tr -d ","`"
sed -i "/^        'HOST': / c\        'HOST': '$BARHOST'," /etc/baruwa/settings.py

# Restore original Baruwa Timezone
BARTIME_ZONE="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep "TIME_ZONE = " | sed 's/.*TIME_ZONE = //' | tr -d "'"`"
sed -i "/^#TIME_ZONE = / c\TIME_ZONE = '$BARTIME_ZONE' " /etc/baruwa/settings.py

# Restore original Baruwa default from email
BARDEFFROMEMAIL="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep "DEFAULT_FROM_EMAIL = " | sed 's/.*DEFAULT_FROM_EMAIL = //' | tr -d "'"`"
sed -i "/^#DEFAULT_FROM_EMAIL = / c\DEFAULT_FROM_EMAIL = '$BARDEFFROMEMAIL' " /etc/baruwa/settings.py

# Restore original Broker Password
BARBROKERPASS="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep "BROKER_PASSWORD = " | sed 's/.*BROKER_PASSWORD = //' | tr -d '"'`"
sed -i "/^BROKER_PASSWORD = / c\BROKER_PASSWORD = \"$BARBROKERPASS\" " /etc/baruwa/settings.py

# Restore original quarantine report hosturl
BARQUARREPURL="`cat /var/EFA/update/0.3/backup/baruwa-settings.py | grep "QUARANTINE_REPORT_HOSTURL =" | sed 's/.*QUARANTINE_REPORT_HOSTURL = //' | tr -d "'"`"
sed -i "/^QUARANTINE_REPORT_HOSTURL = / c\QUARANTINE_REPORT_HOSTURL = '$BARQUARREPURL' " /etc/baruwa/settings.py
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Removing unwanted packages."

dpkg --purge exim4 exim4-base exim4-config exim4-daemon-light
apt-get -q -y remove popularity-contest
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Holding packages"

echo "mailscanner hold" | dpkg --set-selections
echo "baruwa hold" | dpkg --set-selections
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying MailScanner settings"

sed -i '/^Disarmed Modify Subject / c\Disarmed Modify Subject = no' /etc/MailScanner/MailScanner.conf
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying Postfix settings"

MYHOSTNAME="`cat /etc/mailname | sed  's/\..*//'`"
MYDOMAINNAME="`cat /etc/mailname | sed -n 's/[^.]*\.//p'`"
postconf -e mydestination="$MYHOSTNAME.$MYDOMAINNAME, localhost.$MYDOMAINNAME ,localhost"
postconf -e smtpd_recipient_restrictions="permit_sasl_authenticated, permit_mynetworks, reject_unknown_recipient_domain, reject_unauth_destination, whitelist_policy, rbl_policy, spf_policy"
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Updating E.F.A specific files"

# Update EFA-Init file
cd /usr/local/sbin
#mv /usr/local/sbin/EFA-Init /var/EFA/update/0.3/backup/
wget http://www.efa-project.org/build/0.3/usr/local/sbin/EFA-Init
chmod 700 EFA-Init

# Update EFA-Configure file
cd /usr/local/sbin
mv /usr/local/sbin/EFA-Configure /var/EFA/update/0.3/backup/
wget http://www.efa-project.org/build/0.3/usr/local/sbin/EFA-Configure
chmod 700 EFA-Configure

# Update EFA-Update file
cd /usr/local/sbin
mv /usr/local/sbin/EFA-Update /var/EFA/update/0.3/backup/
wget http://www.efa-project.org/build/0.3/usr/local/sbin/EFA-Update
chmod 700 EFA-Update
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Updating baruwa configuration"

mkdir -p /etc/MailScanner/signatures/domains/text
mkdir -p /etc/MailScanner/signatures/domains/html
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying version numbers"

sed -i '/^--- Welcome to EFA / c\--- Welcome to EFA 0.3 ---' /etc/issue
echo "EFA-0.3" > /etc/EFA-version 
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Your system is updated rebooting."

sleep 10
reboot
# +---------------------------------------------------+