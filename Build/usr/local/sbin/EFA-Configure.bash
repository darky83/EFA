#!/bin/bash
# +--------------------------------------------------------------------+
# EFA-Configure
# Version 20130504
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
# - Enable greylisting
# - Disable greylisting
# +--------------------------------------------------------------------+

# +---------------------------------------------------+
# Option IP_SETTINGS
# +---------------------------------------------------+
opt_ip-settings(){
	menu=0
	ipmenu=1
	while [ $ipmenu == "1" ]
		do
			func_getipsettings
			IP="`cat /etc/network/interfaces.d/$INTERFACE | grep address | awk {' print $2 '}`"
			NM="`cat /etc/network/interfaces.d/$INTERFACE | grep netmask | awk {' print $2 '}`"
			GW="`cat /etc/network/interfaces.d/$INTERFACE | grep gateway | awk {' print $2 '}`"
			DNS1="`cat /etc/resolv.conf  | grep nameserver | awk 'NR==1 {print $2}'`"
			DNS2="`cat /etc/resolv.conf  | grep nameserver | awk 'NR==2 {print $2}'`"
			clear         
			echo "----------------- E.F.A -----------------"
			echo "-------------- IP SETTINGS --------------"
			echo " "
			echo "Current IP settings for $INTERFACE are:"
			echo "1) IP:			$IP"
			echo "2) Netmask:		$NM"
			echo "3) Gateway:		$GW"
			echo "4) Primary DNS:		$DNS1"
			echo "5) Secondary DNS:	$DNS2"
			echo ""
			echo "e) Return to main menu"
			echo ""
			echo "Note: Network will reset when changing values."
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
				1) 	ipmenu=0
					echo ""
					read -p "Enter your new IP: " IP
					func_setipsettings
					menu=1
					;;
				2)  ipmenu=0
					echo ""
					read -p "Enter your new netmask: " NM
					func_setipsettings
					menu=1
					;;
				3)  ipmenu=0
					echo ""
					read -p "Enter your new gateway: " GW
					func_setipsettings
					menu=1
					;;
				4) 	ipmenu=0
					echo ""
					read -p "Enter your new primary DNS: " DNS1
					func_setipsettings
					menu=1
					;;
				5) 	ipmenu=0
					echo ""
					read -p "Enter your new secondary DNS: " DNS2
					func_setipsettings
					menu=1
					;;
				e) menu=1 && return ;;
				*) echo -e "Error \"$choice\" is not an option..." && sleep 2
			esac
		done
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Function to grab the current IP settings.
# +---------------------------------------------------+
function func_getipsettings(){

	nrintf=`cat /proc/net/dev | grep eth | awk {' print $1 '} | sed 's/://g' | wc -l`
	interf=`cat /proc/net/dev | grep eth | awk {' print $1 '} | sed 's/://g'`

	if [ $nrintf -gt 1 ]
	 then
		clear         
		echo "----------------- E.F.A -----------------"
		echo "-------------- IP SETTINGS --------------"
		echo " "
		echo "You seem to have multiple network interfaces"
		echo "Please select the interface you want to configure"
		echo "The interface names on your machine are:"
		for int in $interf
			do
				echo " - $int"
			done

        local choice
        read -p "Enter the primary interface name: " choice
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
            echo "ERROR, That interface does not exist."
            sleep 2
            func_getipsettings
            return
          fi

        if [ $choice_check -eq 1 ]
         then
          INTERFACE=$choice
        fi

  else
        INTERFACE=$interf
fi
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Function to set the new IP settings
# +---------------------------------------------------+
func_setipsettings(){
	for ip in $IP $NM $GW $DNS1 $DNS2
		do
			validcheck=1
			while [ $validcheck != 0 ]
				do
					if checkip $ip
						then
							validcheck=0
						else
							echo "ERROR: The value $ip seems to be invalid"
							pause
							return
					fi
				done
		done
	# Grab current FQDN
	HOSTNAME="`cat /etc/mailname | sed  's/\..*//'`"
	DOMAINNAME="`cat /etc/mailname | sed -n 's/[^.]*\.//p'`"

	# Stopping services
	/etc/init.d/rabbitmq-server	stop >> /dev/null

	# Edit hosts file
	echo "127.0.0.1		localhost" > /etc/hosts
	echo "$IP	$HOSTNAME.$DOMAINNAME	$HOSTNAME" >> /etc/hosts
	echo "" >> /etc/hosts
	echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
	echo "::1     ip6-localhost ip6-loopback" >> /etc/hosts
	echo "fe00::0 ip6-localnet" >> /etc/hosts
	echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
	echo "ff02::1 ip6-allnodes" >> /etc/hosts
	echo "ff02::2 ip6-allrouters" >> /etc/hosts

	# Edit resolv.conf
	echo "nameserver $DNS1" > /etc/resolv.conf
	echo "nameserver $DNS2" >> /etc/resolv.conf
	
	/etc/init.d/networking stop >> /dev/null
	# Edit interfaces
	echo "auto $INTERFACE" > /etc/network/interfaces.d/$INTERFACE
	echo "iface $INTERFACE inet static" >> /etc/network/interfaces.d/$INTERFACE
	if [ -n "$IP" ]; then
		echo "        address $IP" >> /etc/network/interfaces.d/$INTERFACE
	fi
	if [ -n "$NM" ]; then
		echo "        netmask $NM" >> /etc/network/interfaces.d/$INTERFACE
	fi
	if [ -n "$GW" ]; then
		echo "        gateway $GW" >> /etc/network/interfaces.d/$INTERFACE
	fi
	if [ -n "$DNS1" ]; then
		echo "        dns-nameservers $DNS1 $DNS2" >> /etc/network/interfaces.d/$INTERFACE
	fi
	
	echo ""
	/etc/init.d/networking start
	/etc/init.d/rabbitmq-server	start >> /dev/null
	echo ""
	pause
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Option HOSTNAME
# +---------------------------------------------------+
opt_hostname(){
	menu=0
	hnmenu=1
	while [ $hnmenu == "1" ]
		do
			HOSTNAME="`cat /etc/mailname | sed  's/\..*//'`"
			DOMAINNAME="`cat /etc/mailname | sed -n 's/[^.]*\.//p'`"
			clear
			echo "----------------- E.F.A -----------------"
			echo "---------------- HOSTNAME ---------------"
			echo ""
			echo "Current Hostname settings are:"
			echo "1) HOSTNAME:		$HOSTNAME"
			echo "2) DOMAIN:		$DOMAINNAME"
			echo ""
			echo "e) Return to main menu"
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
				1) 	hnmenu=0
					echo ""
					read -p "Enter your new hostname: " HOSTNAME
					func_sethnsettings
					hnmenu=1
					;;
				2)	hnmenu=0
					echo ""
					read -p "Enter your new domainname: " DOMAINNAME
					func_sethnsettings
					hnmenu=1
					;;
				e) menu=1 && return ;;
				*) echo -e "Error \"$choice\" is not an option..." && sleep 2
			esac
	done
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Change hostname
# +---------------------------------------------------+
func_sethnsettings(){	
	#first check if HN and DN are valid.
	if [[ ! $HOSTNAME =~ ^[-a-zA-Z0-9]{2,256}+$ ]]
		then
			echo "WARNING: The hostname "$HOSTNAME" seems to be invalid"
			pause
			return
	fi
	if [[ ! $DOMAINNAME =~ ^[-.a-zA-Z0-9]{2,256}+$ ]]
		then
			echo "WARNING: The domain "$DOMAINNAME" seems to be invalid"
			pause
			return
	fi
	
	# Stop services
	/etc/init.d/rabbitmq-server	stop >> /dev/null
	
	# Grab current settings
	func_getipsettings

	# Change Hostname and mailname
	echo $HOSTNAME > /etc/hostname
	echo "$HOSTNAME.$DOMAINNAME" > /etc/mailname  
	
	# Edit hosts file
	echo "127.0.0.1		localhost" > /etc/hosts
	echo "$IP	$HOSTNAME.$DOMAINNAME	$HOSTNAME" >> /etc/hosts
	echo "" >> /etc/hosts
	echo "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
	echo "::1     ip6-localhost ip6-loopback" >> /etc/hosts
	echo "fe00::0 ip6-localnet" >> /etc/hosts
	echo "ff00::0 ip6-mcastprefix" >> /etc/hosts
	echo "ff02::1 ip6-allnodes" >> /etc/hosts
	echo "ff02::2 ip6-allrouters" >> /etc/hosts
	/etc/init.d/hostname.sh
	
	# Change postfix config
	postconf -e myhostname=$HOSTNAME.$DOMAINNAME
	postconf -e mydestination="$HOSTNAME.$DOMAINNAME, localhost.$DOMAINNAME, localhost"
	
	# Change baruwa from email address.
	sed -i "/^DEFAULT_FROM_EMAIL = / c\DEFAULT_FROM_EMAIL = 'postmaster@$DOMAINNAME' " /etc/baruwa/settings.py
	
	# Start services
	/etc/init.d/rabbitmq-server start >> /dev/null
	
	# Reset permissons
	PASSWD=""
	PASSWD="`cat /etc/baruwa/settings.py | grep "BROKER_PASSWORD =" | sed 's/.*BROKER_PASSWORD = //' | tr -d '"'`"
	rabbitmqctl add_user baruwa $PASSWD >> /dev/null
	rabbitmqctl add_vhost baruwa  >> /dev/null
	rabbitmqctl set_permissions -p baruwa baruwa ".*" ".*" ".*" >> /dev/null
	rabbitmqctl delete_user guest >> /dev/null
	
	echo "Settings changed.."
	pause	
}

# +---------------------------------------------------+
# Option Outbound mail relay
# +---------------------------------------------------+
opt_mailrelay(){
	menu=0
	obmrmenu=1
	while [ $obmrmenu == "1" ]
		do
			RELAYS=`cat /etc/postfix/main.cf | grep "mynetworks =" | sed 's/^\(.\{57\}\)//'`
			clear
			echo "----------------- E.F.A -----------------"
			echo "---------- OUTBOUND MAILRELAY -----------"
			echo " "
			echo "Description:"
			echo "With this option you can configure E.F.A"
			echo "to relay outgoing message for your local"
			echo "mailserver or clients."
			echo ""
			echo "Current settings are:"
			echo "1) Hosts:		$RELAYS"
			echo ""
			echo "e) Return to main menu"
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
				1)  obmrmenu=0
					echo ""
					echo "Enter your new hosts string below."
					echo "Note: If you already have hosts defined you need to reenter these."
					echo "      An empty line will remove all hosts."
					echo "      Seperate multiple hosts with spaces."
					echo "      Networks can be defined in the format: x.x.x.x/xx"
					echo ""
					read -p "> " RELAYS
					postconf -e mynetworks="127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 $RELAYS"
					/etc/init.d/postfix reload >>/dev/null
					obmrmenu=1
					;;
				e) menu=1 && return ;;
				*) echo -e "Error \"$choice\" is not an option..." && sleep 2
			esac
	done
}
# +---------------------------------------------------+


# +---------------------------------------------------+
# Option Outbound Smarthost
# +---------------------------------------------------+
opt_smarthost(){
	menu=0
	obshmenu=1
	while [ $obshmenu == "1" ]
		do
			OBSH="`cat /etc/postfix/main.cf |grep "relayhost ="| sed 's/.*relayhost = //'`"

			if [ -z "$OBSH" ]
				then
					OBSH="DISABLED"
			fi
			clear
			echo "----------------- E.F.A -----------------"
			echo "---------- OUTBOUND SMARTHOST -----------"
			echo " "
			echo "Description:"
			echo "With this option you can configure E.F.A"
			echo "to use a external smarthost for outgoing"
			echo "mail. (usefull if you also use E.F.A as"
			echo "an mailrelay)"
			echo ""
			echo "Current settings are:"
			echo "1) Smarthost:		$OBSH"
			echo "2) Disable smarthost"
			echo ""
			echo "e) Return to main menu"
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
				1)  obshmenu=0
					echo ""
					read -p "Enter your new smarthost: " OBSH
					postconf -e relayhost=$OBSH
					/etc/init.d/postfix reload >>/dev/null
					echo "Smarthost configured"
					pause
					obshmenu=1
					;;
				2)  obshmenu=0
					echo ""
					echo "Disabling SmartHost"
					postconf -e relayhost=
					/etc/init.d/postfix reload >>/dev/null
					obshmenu=1
					;;
				e) menu=1 && return ;;
				*) echo -e "Error \"$choice\" is not an option..." && sleep 2
			esac
	done
}
# +---------------------------------------------------+

# +---------------------------------------------------+

# +---------------------------------------------------+
# Option admin email address
# +---------------------------------------------------+
opt_adminemail(){
	menu=0
	aemenu=1
	while [ $aemenu == "1" ]
		do
			ADMINEMAIL="`cat /etc/EFA-Configured | grep ADMINEMAIL | sed 's/.*ADMINEMAIL://'`"
			clear
			echo "----------------- E.F.A -----------------"
			echo "---------- ADMIN EMAIL ADDRESS ----------"
			echo " "
			echo "Description:"
			echo "With this option you can change the E.F.A"
			echo "admin email address."
			echo ""
			echo "Current settings are:"
			echo "1) ADMIN EMAIL:		$ADMINEMAIL"
			echo ""
			echo "e) Return to main menu"
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
				1)  aemenu=0
					echo ""
					read -p "Enter your new admin email: " ADMINEMAIL
					func_setaesettings
					aemenu=1
					;;
				e) menu=1 && return ;;
				*) echo -e "Error \"$choice\" is not an option..." && sleep 2
			esac
	done
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Grey listing
# +---------------------------------------------------+
opt_sqlgrey(){
	menu=0
	greymenu=1
	while [ $greymenu == "1" ]
		do
			func_checkgreylisting
			clear
			echo "----------------- E.F.A -----------------"
			echo "-------------- Greylisting --------------"
			echo " "
			echo "Description:"
			echo "Greylisting will block incoming connections"
			echo "for a few minutes, after that the connection"
			echo "is allowed again."
			echo " "
			echo "Greylisting is currently: $GREYLIST"
			echo " "
			echo "1) Enable"
			echo "2) Disable"
			echo " "
			echo "e) Return to main menu"
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
				1)  greymenu=0
					func_enablegreylisting
					greymenu=1
					;;
				2)  greymenu=0
					func_disablegreylisting
					greymenu=1
					;;
				e)  menu=1 && return ;;
				*) echo -e "Error \"$choice\" is not an option..." && sleep 2
			esac
	done			
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Baruwa Quarantine Report HostURL
# +---------------------------------------------------+
opt_bar-quar-rep-url(){
menu=0
	barquarrepurlmenu=1
	while [ $barquarrepurlmenu == "1" ]
		do
			QUARREPURL="`cat /etc/baruwa/settings.py | grep "QUARANTINE_REPORT_HOSTURL =" | sed 's/.*QUARANTINE_REPORT_HOSTURL = //' | tr -d "'"`"
			clear
			echo "----------------- E.F.A -----------------"
			echo "--- Baruwa Quarantine Report HostURL ----"
			echo " "
			echo "Description:"
			echo "This is the URL that is send in the quarantine"
			echo "report messages by baruwa. By default this is"
			echo "set to the IP of your baruwa installation."
			echo " "
			echo "Current setting is:"
			echo "1) $QUARREPURL"
			echo " "
			echo "e) Return to main menu"
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
				1)  barquarrepurlmenu=0
					echo ""
					read -p "Enter your new URL: " QUARREPURL
					sed -i "/^QUARANTINE_REPORT_HOSTURL = / c\QUARANTINE_REPORT_HOSTURL = '$QUARREPURL' " /etc/baruwa/settings.py
					/etc/init.d/baruwa restart >> /dev/null
					barquarrepurlmenu=1
					;;
				e)  menu=1 && return ;;
				*) echo -e "Error \"$choice\" is not an option..." && sleep 2
			esac
	done			
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Check greylisting status
# +---------------------------------------------------+
func_checkgreylisting(){
	GREYLIST=`cat /etc/EFA-Configured | grep GREYLIST | cut -d ":" -f2`
		if [ -z "$GREYLIST" ]
			then
				GREYLIST="DISABLED"
				GREYLISTINSTALLED="NO"
	fi
}
# +---------------------------------------------------+


# +---------------------------------------------------+
# Enable Greylisting
# +---------------------------------------------------+
func_enablegreylisting(){

	func_checkgreylisting
	if [ "$GREYLIST" = "ENABLED" ]
		then
			echo "Greylisting already enabled"
			pause
		else	
			if [ "$GREYLISTINSTALLED" = "NO" ]
				then
					clear
					echo "Starting SQL Grey installation"
					
					# TODO
					# Install greylisting
					# Configure greylisting
					# check enable/disable methode

					echo "GREYLIST:ENABLED" >> /etc/EFA-Configured
					pause
				else
					clear
					echo "Enabling SQL Grey"
					# TODO
					# Configure Greylisting
					
					sed -i "/^GREYLIST:/ c\GREYLIST:ENABLED" /etc/EFA-Configured
					pause
			fi
	fi
}
# +---------------------------------------------------+
		
# +---------------------------------------------------+
# Disable Greylisting
# +---------------------------------------------------+
func_disablegreylisting(){

	func_checkgreylisting
	if [ "$GREYLIST" = "DISABLED" ]
		then
			echo "Greylisting already disabled"
			pause
		else
			
			# TODO
			# Disable greylisting
			
			sed -i "/^GREYLIST:/ c\GREYLIST:DISABLED" /etc/EFA-Configured
	fi
}
# +---------------------------------------------------+


# +---------------------------------------------------+
# Change hostname
# +---------------------------------------------------+
func_setaesettings(){	
	if [[ ! $ADMINEMAIL =~ ^[-_.@Aa-zA-Z0-9]{2,256}+$ ]]
		then
    		echo "WARNING: The adres $ADMINEMAIL seems to be invalid"
	fi
	
	echo "root $ADMINEMAIL" > /etc/postfix/virtual
	echo "abuse $ADMINEMAIL" >> /etc/postfix/virtual
	echo "postmaster $ADMINEMAIL" >> /etc/postfix/virtual
	postmap /etc/postfix/virtual
	
	sed -i "/^ADMINEMAIL:/ c\ADMINEMAIL:$ADMINEMAIL" /etc/EFA-Configured 
	
	echo "Settings changed.."
	pause
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Display menus
# +---------------------------------------------------+
show_menus() {
	clear
	echo "----------------- E.F.A -----------------"
	echo "--------------- MAIN MENU ---------------"
	echo " " 
	echo "Please select the item you want to modify"
	echo " "
	echo "+- System settings:"
	echo "1) IP settings"
	echo "2) Hostname"
	echo ""
	echo "+- Mail related items:"
	echo "3) Outbound mail relay"
	echo "4) Outbound smarthost" 
	echo "5) Admin Email address"
	echo "6) Grey listing"
	echo ""
	echo "+- Baruwa settings:"
	echo "7) Quarantine report hosturl"
	echo " "
	echo "e. Exit"
}
# read input from the keyboard and take a action
read_options(){
	local choice
	read -p "Enter choice: " choice
	case $choice in
		1) opt_ip-settings ;;
		2) opt_hostname ;;
		3) opt_mailrelay ;;
		4) opt_smarthost ;;
		5) opt_adminemail ;;
		6) opt_sqlgrey ;;
		7) opt_bar-quar-rep-url;;
		e) exit 0;;
		*) echo -e "Error \"$choice\" is not an option..." && sleep 2
	esac
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Trap CTRL+C, CTRL+Z and quit singles
# +---------------------------------------------------+
trap '' SIGINT SIGQUIT SIGTSTP
# +---------------------------------------------------+

# +---------------------------------------------------+
# Pause
# +---------------------------------------------------+
pause(){
	read -p "Press [Enter] key to continue..." fackEnterKey
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Function to test IP addresses
# +---------------------------------------------------+
function checkip(){
	local ip=$1
	local stat=1

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
# Main logic
# +---------------------------------------------------+

if [ `whoami` == root ]
	then
		menu="1"
		while [ $menu == "1" ]
		do
			show_menus
			read_options
		done
	else
		echo "[EFA] ERROR: Please become root."
		exit 0
	fi
# +---------------------------------------------------+