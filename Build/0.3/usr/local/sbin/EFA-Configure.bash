#!/bin/bash
# +---------------------------------------------------+
# EFA-Reconfigure
# V0.1-20121115
# +---------------------------------------------------+

# +---------------------------------------------------+
# Option IP_SETTINGS
# +---------------------------------------------------+
opt_ip-settings(){
	menu=0
	ipmenu=1
	while [ $ipmenu == "1" ]
		do
			func_getipsettings
			clear         
    		echo "----------------- E.F.A -----------------"
    		echo "-------------- IP SETTINGS --------------"
    		echo " "
    		echo "Current IP settings are:"
    		echo "1) IP:		$IP"
			echo "2) Netmask:	$NM"
			echo "3) Gateway:	$GW"
			echo "4) Primary DNS:	$DNS1"
			echo "5) Secondary DNS:	$DNS2"
			echo ""
			echo "e) Return to main menu"
			echo ""
			local choice
			read -p "Enter setting you want to change: " choice
			case $choice in
    			1) 	ipmenu=0
    				echo ""
    				read -p "Enter your new IP: " IP
    				func_setipsettings
    				ipmenu=1
    				;;
        		2) ipmenu=0
    				echo ""
    				read -p "Enter your new netmask: " NM
    				func_setipsettings
    				ipmenu=1
    				;;
        		3) 	ipmenu=0
    				echo ""
    				read -p "Enter your new gateway: " GW
    				func_setipsettings
    				ipmenu=1
    				;;
        		4) 	ipmenu=0
    				echo ""
    				read -p "Enter your new primary DNS: " DNS1
    				func_setipsettings
    				ipmenu=1
    				;;
        		5) 	ipmenu=0
    				echo ""
    				read -p "Enter your new secondary DNS: " DNS2
    				func_setipsettings
    				ipmenu=1
    				;;
        		e) menu=1 && return ;;
        		*) echo -e "Error \"$choice\" is not an option..." && sleep 2
    		esac
		done
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
    					echo "OK  $ip"
    					validcheck=0
    				else
    					echo "ERROR: The value $ip seems to be invalid"
    					pause
    					return
				fi
			done
	done
echo ""
echo $IP
echo $NM
echo $GW
echo $DNS1
echo $DNS2
pause
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Option HOSTNAME
# +---------------------------------------------------+
opt_hostname(){
	clear        
    echo "----------------- E.F.A -----------------"
    echo "---------------- HOSTNAME ---------------"
    echo ""
    pause
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Option Outbound mail relay
# +---------------------------------------------------+
opt_mailrelay(){
	clear        
    echo "----------------- E.F.A -----------------"
    echo "---------- OUTBOUND MAILRELAY -----------"
    echo " "
    echo "Description"
    echo "With this option you can configure E.F.A"
    echo "to relay outgoing message for your local"
    echo "mailserver or clients"
    pause
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Option Outbound Smarthost
# +---------------------------------------------------+
opt_smarthost(){
	clear      
    echo "----------------- E.F.A -----------------"
    echo "---------- OUTBOUND SMARTHOST -----------"
    echo " "
    echo "Description:"
    echo "With this option you can configure E.F.A"
    echo "to use a external smarthost for outgoing"
    echo "mail."
    pause
}
# +---------------------------------------------------+

# +---------------------------------------------------+

# +---------------------------------------------------+
# Option Outbound Smarthost
# +---------------------------------------------------+
opt_adminemail(){
	clear      
    echo "----------------- E.F.A -----------------"
    echo "---------- ADMIN EMAIL ADDRESS ----------"
    echo " "
    echo "Description:"
    echo "With this option you can change the E.F.A"
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
# Function to grab the current IP settings.
# +---------------------------------------------------+
function func_getipsettings(){
	IP="`cat /etc/network/interfaces | grep address | awk {' print $2 '}`"
	NM="`cat /etc/network/interfaces | grep netmask | awk {' print $2 '}`"
	GW="`cat /etc/network/interfaces | grep gateway | awk {' print $2 '}`"
	DNS1="`cat /etc/resolv.conf  | grep nameserver | awk 'NR==1 {print $2}'`"
	DNS2="`cat /etc/resolv.conf  | grep nameserver | awk 'NR==2 {print $2}'`"
}
# +---------------------------------------------------+

# +---------------------------------------------------+
# Function to test IP addresses
# +---------------------------------------------------+
function checkip(){
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