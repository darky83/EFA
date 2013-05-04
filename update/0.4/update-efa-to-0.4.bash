#!/bin/bash
# +---------------------------------------------------+
# EFA 0.4 update script
# version 20130405
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
mkdir /var/EFA/update/0.4
mkdir /var/EFA/update/0.4/backup
cp /etc/baruwa/settings.py /var/EFA/update/0.4/backup/baruwa-settings.py
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Holding packages"

echo "mailscanner hold" | dpkg --set-selections
echo "baruwa hold" | dpkg --set-selections
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying MailScanner settings"
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying Postfix settings"
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Updating E.F.A specific files"

# Update EFA-Init file
cd /usr/local/sbin
mv /usr/local/sbin/EFA-Init /var/EFA/update/0.4/backup/
wget http://www.efa-project.org/build/0.4/usr/local/sbin/EFA-Init
chmod 700 EFA-Init

# Update EFA-Configure file
cd /usr/local/sbin
mv /usr/local/sbin/EFA-Configure /var/EFA/update/0.4/backup/
wget http://www.efa-project.org/build/0.4/usr/local/sbin/EFA-Configure
chmod 700 EFA-Configure

# Update EFA-Update file
cd /usr/local/sbin
mv /usr/local/sbin/EFA-Update /var/EFA/update/0.4/backup/
wget http://www.efa-project.org/build/0.4/usr/local/sbin/EFA-Update
chmod 700 EFA-Update
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Updating baruwa configuration"

# Fix postmaster account domain
DOMAINNAME="`cat /etc/mailname | sed -n 's/[^.]*\.//p'`"
sed -i "/^DEFAULT_FROM_EMAIL = / c\DEFAULT_FROM_EMAIL = 'postmaster@$DOMAINNAME' " /etc/baruwa/settings.py

mkdir -p /etc/MailScanner/signatures/domains/text
mkdir -p /etc/MailScanner/signatures/domains/html
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Install 3.2 kernel from backports for hyper-v support"
echo "deb http://backports.debian.org/debian-backports squeeze-backports main" > /etc/apt/sources.list.d/backports.list
apt-get update
export APT_LISTCHANGES_FRONTEND=none
apt-get -y -t squeeze-backports install linux-headers-3.2.0-0.bpo.4-686-pae linux-image-3.2.0-0.bpo.4-686-pae
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Modifying version numbers"

sed -i '/^--- Welcome to EFA / c\--- Welcome to EFA 0.4 ---' /etc/issue
echo "EFA-0.4" > /etc/EFA-version 
# +---------------------------------------------------+

# +---------------------------------------------------+
echo "[EFA] Your system is updated rebooting."

sleep 10
reboot
# +---------------------------------------------------+