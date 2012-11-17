#!/bin/bash
# +---------------------------------------------------+
# EFA 0.3 update script
# version 20121111
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

apt-get update
apt-get -y upgrade

dpkg -purge exim4 exim4-base exim4-config exim4-daemon-light
apt-get remove popularity-contest
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
echo "[EFA] Modifying version numbers"

# /etc/issue
# +---------------------------------------------------+
