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
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying MailScanner settings"

sed -i '/^Disarmed Modify Subject / c\Disarmed Modify Subject = no' /etc/MailScanner/MailScanner.conf
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying Postfix settings"

MYHOSTNAME="TODO TODO TODO TODO TODO"
MYDOMAINNAME="TODO TODO TODO TODO TODO"
postconf -e mydestination="$MYHOSTNAME.$MYDOMAINNAME, localhost.$MYDOMAINNAME ,localhost"
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Updating E.F.A specific files"

# Update EFA-Configure file
cd /usr/local/sbin
wget http://www.efa-project.org/build/0.3/usr/local/sbin/EFA-Configure
chmod 700 EFA-Configure

# Update EFA-Update file
wget http://www.efa-project.org/build/0.3/usr/local/sbin/EFA-Update
chmod 700 EFA-Update
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying version numbers"

# /etc/issue
# +---------------------------------------------------+
