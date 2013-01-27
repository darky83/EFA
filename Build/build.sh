#!/bin/bash
# +--------------------------------------------------------------------+
# EFA build script version 20130127
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
#
# This creates the base for EFA.
# +---------------------------------------------------+
# STAGE 0 (Pre requirements for barebone install)
# +---------------------------------------------------+
# - Configure Hardware
# - Install Debian minimal with following disk layout
#     / 		( 6GB)
#     /tmp 		( 1GB)
#     /var		(12GB)
#     /var/spool	(60GB)
#     swap		( 1GB)
# - Set /tmp "noexec,nosuid" in /etc/fstab
# - Configure IP settings
# - Create user efaadmin
#
# Firewall ports needed
# TCP 25 out (mail)
# UDP 24441 out (pyzor)
# UDP 6277 out (DCC)
# TCP 2703 out (Razor)
#
# +++++++++++++++++++++++++++++++++++++++++++++++++++++
# STAGE 1 System setup
# +++++++++++++++++++++++++++++++++++++++++++++++++++++
VERSION="0.4"

# Apt settings for noexec /tmp dir
echo 'DPkg:Pre-Invoke{"mount -o remount,exec /tmp";};' >> /etc/apt/apt.conf
echo 'DPkg:Post-Invoke {"mount -o remount /tmp";};' >> /etc/apt/apt.conf

# Stop unneeded services
update-rc.d -f mpt-statusd remove
update-rc.d -f nfs-common remove
update-rc.d -f exim4 remove
update-rc.d -f portmap remove
# +++++++++++++++++++++++++++++++++++++++++++++++++++++

# +++++++++++++++++++++++++++++++++++++++++++++++++++++
# STAGE 2 Installation
# +++++++++++++++++++++++++++++++++++++++++++++++++++++

# +---------------------------------------------------+
# Install needed packages
apt-get update
#export DEBIAN_FRONTEND=noninteractive
echo "mysql-server-5.1 mysql-server/root_password_again password password" | debconf-set-selections
echo "mysql-server-5.1 mysql-server/root_password password password" | debconf-set-selections
echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
echo "postfix postfix/mailname string efa03.efa-project.org" | debconf-set-selections


apt-get -q -y install unrar-free vim screen htop ssh ntp mysql-server-5.1 apache2 postfix postfix-mysql rabbitmq-server pyzor razor sudo postfix-policyd-spf-perl
dpkg --purge exim4 exim4-base exim4-config exim4-daemon-light
apt-get -q -y remove popularity-contest
# +---------------------------------------------------+

# +---------------------------------------------------+
# Basic config of rabbitMQ
sed -i '/^# Default-Start:/ c\# Default-Start: 2 3 4 5' /etc/init.d/rabbitmq-server
sed -i '/^# Default-Stop:/ c\# Default-Stop: 0 1 6' /etc/init.d/rabbitmq-server
update-rc.d rabbitmq-server defaults
rabbitmqctl add_user baruwa password
rabbitmqctl add_vhost baruwa
rabbitmqctl set_permissions -p baruwa baruwa ".*" ".*" ".*"
rabbitmqctl delete_user guest
# +---------------------------------------------------+

# +---------------------------------------------------+
# Install baruwa
wget -O - http://apt.baruwa.org/baruwa-apt-keys.gpg | apt-key add -
echo "deb http://apt.baruwa.org/debian squeeze main" >> /etc/apt/sources.list.d/baruwa.list
apt-get update
# Configure MySQL: yes

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

apt-get -q -y install baruwa
baruwa-admin syncdb --noinput
for name in $(echo "accounts messages lists reports status fixups config"); do
 baruwa-admin migrate $name;
done

mkdir -p /etc/MailScanner/signatures/domains/text
mkdir -p /etc/MailScanner/signatures/domains/html
# +---------------------------------------------------+


# +---------------------------------------------------+
# Configure permissions
mkdir /var/spool/MailScanner/spamassassin
chown -R postfix:postfix /var/spool/MailScanner/incoming
chmod -R 770 /var/spool/MailScanner/incoming
chmod -R 775 /var/spool/MailScanner/quarantine
chmod -R 775 /var/spool/MailScanner
# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure MailScanner
cp /etc/MailScanner/MailScanner.conf /etc/MailScanner/MailScanner.conf.dist
sed -i '/^Run As User/ c\Run As User = postfix' /etc/MailScanner/MailScanner.conf
sed -i '/^Run As Group/ c\Run As Group = postfix' /etc/MailScanner/MailScanner.conf
sed -i '/^Incoming Queue Dir/ c\Incoming Queue Dir = \/var\/spool\/postfix\/hold' /etc/MailScanner/MailScanner.conf
sed -i '/^Outgoing Queue Dir/ c\Outgoing Queue Dir = \/var\/spool\/postfix\/incoming' /etc/MailScanner/MailScanner.conf
# Names
sed -i '/^%org-name% =/ c\%org-name% = EFA' /etc/MailScanner/MailScanner.conf
sed -i '/^%org-long-name% =/ c\%org-long-name% = EFA-Project' /etc/MailScanner/MailScanner.conf
sed -i '/^%web-site% =/ c\%web-site% = www.efa-project.org' /etc/MailScanner/MailScanner.conf
sed -i 's/X-%org-name%-MailScanner/X-%org-name%-MailScanner/g' /etc/MailScanner/MailScanner.conf
# Use Postfix
sed -i '/^MTA = / c\MTA = postfix' /etc/MailScanner/MailScanner.conf
# System settings
sed -i '/^Max Children =/ c\Max Children = 2' /etc/MailScanner/MailScanner.conf
sed -i '/^Log Spam =/ c\Log Spam = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Log Silent Viruses =/ c\Log Silent Viruses = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Log Dangerous HTML Tags =/ c\Log Dangerous HTML Tags = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Detailed Spam Report =/ c\Detailed Spam Report = yes' /etc/MailScanner/MailScanner.conf
# ClamAV Settings
sed -i '/^Virus Scanners / c\Virus Scanners = clamd' /etc/MailScanner/MailScanner.conf
sed -i '/^Clamd Socket =/ c\Clamd Socket = /var/run/clamav/clamd.ctl' /etc/MailScanner/MailScanner.conf
# SpamAssassin Settings
sed -i '/^SpamAssassin User State Dir/ c\SpamAssassin User State Dir  = /var/spool/MailScanner/spamassassin' /etc/MailScanner/MailScanner.conf
sed -i '/^Include Scores In SpamAssassin Report =/ c\Include Scores In SpamAssassin Report = yes' /etc/MailScanner/MailScanner.conf
#sed -i '/^Incoming Work Group =/ c\Incoming Work Group = clamav' /etc/MailScanner/MailScanner.conf
sed -i '/^Incoming Work Permissions/ c\Incoming Work Permissions = 0644' /etc/MailScanner/MailScanner.conf
# Quarantine Settings
sed -i '/^Quarantine User =/ c\Quarantine User = postfix' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine User =/ c\Quarantine User = postfix' /etc/MailScanner/conf.d/baruwa.conf
sed -i '/^Quarantine Group =/ c\Quarantine Group = celeryd' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine Permissions =/ c\Quarantine Permissions = 0660' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine Whole Message =/ c\Quarantine Whole Message = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Quarantine Infections =/ c\Quarantine Infections = no' /etc/MailScanner/MailScanner.conf
sed -i '/^Deliver Unparsable TNEF =/ c\Deliver Unparsable TNEF = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Maximum Archive Depth =/ c\Maximum Archive Depth = 0' /etc/MailScanner/MailScanner.conf
sed -i '/^Keep Spam And MCP Archive Clean =/ c\Keep Spam And MCP Archive Clean = yes' /etc/MailScanner/MailScanner.conf
sed -i '/^Required SpamAssassin Score =/ c\Required SpamAssassin Score = 4' /etc/MailScanner/MailScanner.conf
sed -i '/^Spam Actions =/ c\Spam Actions = store notify' /etc/MailScanner/MailScanner.conf
sed -i '/^High Scoring Spam Actions =/ c\High Scoring Spam Actions = store' /etc/MailScanner/MailScanner.conf
sed -i '/^Non Spam Actions =/ c\Non Spam Actions = store deliver header "X-Spam-Status: No"' /etc/MailScanner/MailScanner.conf
sed -i '/^SpamAssassin Local State Dir =/ c\SpamAssassin Local State Dir = /var/lib/spamassassin' /etc/MailScanner/MailScanner.conf

sed -i '/^Sign Clean Messages / c\Sign Clean Messages = no' /etc/MailScanner/MailScanner.conf
sed -i '/^Sign Clean Messages / c\Sign Clean Messages = no' /etc/MailScanner/conf.d/baruwa.conf


sed -i '/^Disarmed Modify Subject / c\Disarmed Modify Subject = no' /etc/MailScanner/MailScanner.conf

# Fix debian bug
sed -i '/^#!\/usr\/bin\/perl -I\/usr\/share\/MailScanner/ c\#!\/usr\/bin\/perl -I\/usr\/share\/MailScanner\ -U' /usr/sbin/MailScanner

# finally enable mailscanner
sed -i '/^#run_mailscanner=1/ c\run_mailscanner=1' /etc/default/mailscanner
# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure Spamasassin
sed -i '/^envelope_sender_header / c\envelope_sender_header X-EFA-MailScanner-From' /etc/MailScanner/spam.assassin.prefs.conf
sed -i '/^use_auto_whitelist 0/ c\#use_auto_whitelist 0' /etc/MailScanner/spam.assassin.prefs.conf

sed -i '/^ENABLED=0/ c\ENABLED=1' /etc/default/spamassassin
sa-update

# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure clamav
usermod -g postfix clamav
usermod -a -G clamav clamav
# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure Pyzor
# +---------------------------------------------------+
mkdir /var/spool/postfix/.pyzor
chown postfix:postfix /var/spool/postfix/.pyzor

# workaround the debian deprication message..
sed -i '/^#!\/usr\/bin\/python/ c\#!\/usr\/bin\/python -Wignore::DeprecationWarning' /usr/bin/pyzor
# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure razor
# +---------------------------------------------------+
mkdir /root/.razor
#razor-admin -d -create
#razor-admin -register
# +---------------------------------------------------+


# +---------------------------------------------------+
# Configure postfix
chsh postfix -s /usr/sbin/nologin
cp /etc/postfix/main.cf /etc/postfix/main.cf.dist
postconf -e header_checks=regexp:/etc/postfix/header_checks
echo '/^Received:/ HOLD' > /etc/postfix/header_checks
postconf -e inet_interfaces=all
postconf -e myhostname=`cat /etc/hostname`.efa-project.org
postconf -e disable_vrfy_command=yes
postconf -e smtpd_banner="$myhostname ESMTP EFA www.efa-project.org"
postconf -e queue_directory=/var/spool/postfix
postconf -e mail_owner=postfix
postconf -e unknown_local_recipient_reject_code=550
postconf -e local_transport="error:No local mail delivery"
postconf -e smtpd_delay_reject="yes"
postconf -e smtpd_recipient_limit="100"
postconf -e smtpd_helo_required="yes"
postconf -e message_size_limit=512000000
postconf -e mailbox_size_limit=512000000
postconf -e smtpd_client_restrictions="permit_sasl_authenticated"
postconf -e smtpd_sender_restrictions="permit_sasl_authenticated, check_sender_access hash:/etc/postfix/sender_access, reject_non_fqdn_sender, reject_unknown_sender_domain"
postconf -e smtpd_helo_restrictions="permit_sasl_authenticated check_helo_access hash:/etc/postfix/helo_access, reject_invalid_hostname"
postconf -e smtpd_recipient_restrictions="permit_sasl_authenticated, permit_mynetworks, reject_unknown_recipient_domain, reject_unauth_destination, whitelist_policy, rbl_policy, spf_policy"
postconf -e smtpd_data_restrictions="permit_sasl_authenticated, reject_unauth_pipelining"
postconf -e smtpd_restriction_classes="spf_policy, rbl_policy, whitelist_policy"
postconf -e spf_policy="check_policy_service unix:private/policy"
postconf -e rbl_policy="reject_rbl_client zen.spamhaus.org, reject_rbl_client bl.spamcop.net"
postconf -e whitelist_policy="check_client_access mysql:/etc/postfix/mysql-global_lists.cf, check_sender_access mysql:/etc/postfix/mysql-global_lists.cf"
postconf -e virtual_alias_maps=hash:/etc/postfix/virtual
touch /etc/postfix/virtual
postmap /etc/postfix/virtual
touch /etc/postfix/sender_access
postmap /etc/postfix/sender_access
touch /etc/postfix/helo_access
postmap /etc/postfix/helo_access

echo "policy unix - n n - - spawn user=nobody argv=/usr/sbin/postfix-policyd-spf-perl" >> /etc/postfix/master.cf

postconf -e relay_domains=mysql:/etc/postfix/mysql-relay_domains.cf
echo "user = baruwa" >> /etc/postfix/mysql-relay_domains.cf
echo "password = password" >> /etc/postfix/mysql-relay_domains.cf
echo "dbname = baruwa" >> /etc/postfix/mysql-relay_domains.cf
echo "query = SELECT address FROM user_addresses WHERE address='%s' AND enabled=1 AND address_type=1;" >> /etc/postfix/mysql-relay_domains.cf
echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-relay_domains.cf

postconf -e transport_maps=mysql:/etc/postfix/mysql-transports.cf
echo "user = baruwa" >> /etc/postfix/mysql-transports.cf
echo "password = password" >> /etc/postfix/mysql-transports.cf
echo "dbname = baruwa" >> /etc/postfix/mysql-transports.cf
echo "query = SELECT CONCAT('smtp:[', mail_hosts.address, ']:', port) FROM mail_hosts, user_addresses WHERE user_addresses.address = '%s' AND user_addresses.id = mail_hosts.useraddress_id;" >> /etc/postfix/mysql-transports.cf
echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-transports.cf

#postconf -e relay_recipient_maps=mysql:/etc/postfix/mysql-relay_recipients.cf
echo "user = baruwa" >> /etc/postfix/mysql-relay_recipients.cf
echo "password = password" >> /etc/postfix/mysql-relay_recipients.cf
echo "dbname = baruwa" >> /etc/postfix/mysql-relay_recipients.cf
echo "query = SELECT 1 FROM user_addresses WHERE address='%s' AND address_type=2 UNION SELECT 1 FROM auth_user WHERE username = '%s' OR email = '%s'; " >> /etc/postfix/mysql-relay_recipients.cf
echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-relay_recipients.cf

echo "user = baruwa" >> /etc/postfix/mysql-global_lists.cf
echo "password = password" >> /etc/postfix/mysql-global_lists.cf
echo "dbname = baruwa" >> /etc/postfix/mysql-global_lists.cf
echo "query = SELECT CONCAT('PERMIT') FROM lists WHERE from_address='%s' AND list_type=1 UNION SELECT CONCAT('REJECT') FROM lists WHERE from_address='%s' AND list_type=2; " >> /etc/postfix/mysql-global_lists.cf
echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-global_lists.cf
# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure Baruwa
#baruwa-admin createsuperuser
#baruwa-admin initconfig
sed -i "/^#DEFAULT_FROM_EMAIL = / c\DEFAULT_FROM_EMAIL = 'postmaster@efa-project.org' " /etc/baruwa/settings.py
sed -i "/^QUARANTINE_REPORT_HOSTURL = / c\QUARANTINE_REPORT_HOSTURL = 'http://`ifconfig eth0|grep "inet addr:"|awk '{print $2}'|awk -F : '{print $2}'`' " /etc/baruwa/settings.py
update-rc.d baruwa defaults
# Don't start yet we do this after config
rm /etc/rc2.d/S17baruwa 
# +---------------------------------------------------+

# +---------------------------------------------------+
# Install & Configure DCC
cd /usr/src
wget http://www.efa-project.org/build/$VERSION/install/dcc.tar.Z
tar xvzf dcc.tar.Z
cd dcc-1.3.143/
./configure
make
make install

# Configure DCC and run as daemon for better performance
ln -s /var/dcc/libexec/cron-dccd /usr/bin/cron-dccd
ln -s /var/dcc/libexec/cron-dccd /etc/cron.monthly/cron-dccd
echo "dcc_home /var/dcc" >> /etc/MailScanner/spam.assassin.prefs.conf
sed -i '/^dcc_path / c\dcc_path /usr/local/bin/dccproc' /etc/MailScanner/spam.assassin.prefs.conf
sed -i '/^DCCIFD_ENABLE=/ c\DCCIFD_ENABLE=on' /var/dcc/dcc_conf
sed -i '/^DBCLEAN_LOGDAYS=/ c\DBCLEAN_LOGDAYS=1' /var/dcc/dcc_conf
sed -i '/^DCCIFD_LOGDIR=/ c\DCCIFD_LOGDIR="/var/dcc/log"' /var/dcc/dcc_conf
chown postfix:postfix /var/dcc
sed -i "s/#loadplugin Mail::SpamAssassin::Plugin::DCC/loadplugin Mail::SpamAssassin::Plugin::DCC/g" /etc/spamassassin/v310.pre
sed -i "s/# loadplugin Mail::SpamAssassin::Plugin::RelayCountry/loadplugin Mail::SpamAssassin::Plugin::RelayCountry/g" /etc/spamassassin/init.pre
cd /etc/init.d
wget http://www.efa-project.org/build/$VERSION/etc/init.d/DCC
chmod 755 /etc/init.d/DCC
# +---------------------------------------------------+

# +---------------------------------------------------+
# Configure apache
a2dissite 000-default
sed -i '/ServerName /d' /etc/apache2/sites-enabled/baruwa
# +---------------------------------------------------+

# +---------------------------------------------------+
# Fix baruwa cron & set update cron's
echo "# baruwa - 1.1.0" > /etc/cron.d/baruwa
echo "#" >> /etc/cron.d/baruwa
echo "# runs every 3 mins to update mailq stats" >> /etc/cron.d/baruwa
echo "" >> /etc/cron.d/baruwa
echo "*/3 * * * * root baruwa-admin queuestats >>/dev/null" >> /etc/cron.d/baruwa

echo "37 5 * * * /usr/sbin/update_phishing_sites >> /dev/null" >> /etc/cron.d/efa
echo "07 * * * * /usr/sbin/update_bad_phishing_emails >> /dev/null" >> /etc/cron.d/efa
echo "42 * * * * /usr/sbin/update_virus_scanners >> /dev/null" >> /etc/cron.d/efa
# +---------------------------------------------------+

# +---------------------------------------------------+
# Write specific EFA files
echo "EFA-$VERSION" >> /etc/EFA-version
cd /usr/local/sbin
wget http://www.efa-project.org/build/$VERSION/usr/local/sbin/EFA-Init
chmod 700 EFA-Init
wget http://www.efa-project.org/build/$VERSION/usr/local/sbin/EFA-Configure
chmod 700 EFA-Configure
wget http://www.efa-project.org/build/$VERSION/usr/local/sbin/EFA-Update
chmod 700 EFA-Update
mkdir /var/EFA
mkdir /var/EFA/update

echo "" >> /etc/issue
echo "--------------------------" >> /etc/issue
echo "--- Welcome to EFA $VERSION ---" >> /etc/issue
echo "--------------------------" >> /etc/issue
echo "http://www.efa-project.org" >> /etc/issue
echo "--------------------------" >> /etc/issue
echo "" >> /etc/issue
echo "First time login: root/password" >> /etc/issue

# Set EFA-Init to run at first root login:
sed -i '1i\\/usr\/local\/sbin\/EFA-Init' /root/.bashrc

# +---------------------------------------------------+
# Monthly check for update
cd /etc/cron.monthly
wget http://www.efa-project.org/build/$VERSION/etc/cron.monthly/EFA-Monthly-cron
chmod 700 EFA-Monthly-cron
# +---------------------------------------------------+

# +---------------------------------------------------+
# Secure SSH
sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config

# Clean SSH keys (gererate at first boot)
/bin/rm /etc/ssh/ssh_host_*
# +---------------------------------------------------+

# +---------------------------------------------------+
# Disable all services untill we are configured
update-rc.d apache2 disable
update-rc.d rabbitmq-server disable
update-rc.d mysql disable
update-rc.d mailscanner disable
update-rc.d spamassassin disable
update-rc.d ssh disable
update-rc.d clamav-freshclam disable
update-rc.d postfix disable
# +---------------------------------------------------+

# +---------------------------------------------------+
# Hold a few packages.
echo "mailscanner hold" | dpkg --set-selections
echo "baruwa hold" | dpkg --set-selections
# +---------------------------------------------------+

# +---------------------------------------------------+
# Cleanup
rm /var/cache/apt/archives/*
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo " " >> /etc/network/interfaces
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "127.0.0.1               localhost efa02" > /etc/hosts
# +---------------------------------------------------+

# +---------------------------------------------------+
reboot
#EOF