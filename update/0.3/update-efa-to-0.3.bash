#!/bin/bash
# +---------------------------------------------------+
# EFA 0.3 update script
# version 20130103
# TODO
# - FIX SIGNATURES
# - 
# +---------------------------------------------------+
echo ""
echo "[EFA] Did you create a snapshot of your system?" 
echo "[EFA] Giving you 30 seconds to abort (Ctrl-c)" 
echo ""
sleep 30
echo ""
echo "[EFA] Starting update"
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Updating system packages"

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
apt-get -q -y upgrade

dpkg --purge exim4 exim4-base exim4-config exim4-daemon-light
apt-get -q -y remove popularity-contest

# Hold a few packages.
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

mkdir /var/EFA/update/0.3
mkdir /var/EFA/update/0.3/backup

# Update EFA-Init file
cd /usr/local/sbin
mv /usr/local/sbin/EFA-Init /var/EFA/update/0.3/backup/
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
