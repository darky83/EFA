#!/bin/bash
# +---------------------------------------------------+
# EFA 0.3 update script
# version 20121101
# +---------------------------------------------------+
echo ""
echo "[EFA] Did you create a snapshot of your system?" 
echo "[EFA] Giving you 30 seconds to abort (Ctrl-c)" 
echo ""
sleep 30
echo ""
echo "[EFA] Starting update"
echo "[EFA] Updating system packages"
apt-get update
apt-get -y upgrade

echo "[EFA] Modifying MailScanner settings"
sed -i '/^Disarmed Modify Subject / c\Disarmed Modify Subject = no' /etc/MailScanner/MailScanner.conf

MYHOSTNAME=""
MYDOMAINNAME=""
postconf -e mydestination="$MYHOSTNAME.$MYDOMAINNAME, localhost.$MYDOMAINNAME ,localhost"
