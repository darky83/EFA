#!/bin/bash
# +--------------------------------------------------------------------+
# EFA Project update script 
# Version 0.3-20121101
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
action="$1"
################################################################

#----------------------------------------------------------------#
# Variables
#----------------------------------------------------------------#
MIRROR1="http://www.efa-project.org"
VERSIONFILE="/etc/EFA-version"
ADMINEMAIL="`cat /etc/EFA-Configured | sed 's/.*ADMINEMAIL://'`"
MAILFROM="$ADMINEMAIL"
MAILTO="$ADMINEMAIL"
MAILSUBJECT="New EFA version available for `hostname`"
SENDMAIL="/usr/lib/sendmail"
TMPMAIL="/tmp/tempmail"
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Function start_update
#----------------------------------------------------------------#
function start_update()
{
  CVERSION="`cat $VERSIONFILE`"
  get_version
   if [ "$CVERSION" == "$LVERSION" ]
    then
      echo "[EFA] You are already running the latest version, no update needed"
      exit 0
    else
      echo "[EFA] Starting update to $LVERSION"
      cd /var/EFA/update
      if [ -f /var/EFA/update/EFA-update-script ]
        then 
          rm /var/EFA/update/EFA-update-script
      fi
      wget -q $MIRROR1/update/EFA-update-script
      chmod 700 EFA-update-script
      /var/EFA/update/EFA-update-script
  fi
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Function check_update
#----------------------------------------------------------------#
function check_update()
{
  CVERSION="`cat $VERSIONFILE`"
  echo "[EFA] Getting latest version number from $MIRROR1"
  get_version
  if [ "$CVERSION" == "$LVERSION" ]
    then
      echo "[EFA] You are already running version $LVERSION, no update needed"
      exit 0
    else
      echo "[EFA] You are running EFA version $CVERSION"
      echo "[EFA] Latest version update is $LVERSION."
      exit 0
  fi
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Function cron_check
#----------------------------------------------------------------#
function cron_check()
{
  CVERSION="`cat $VERSIONFILE`"
  get-version
  if [ "$CVERSION" == "$LVERSION" ]
    then
      echo "From: $MAILFROM" > $TMPMAIL
      echo "To: $MAILTO" >> $TMPMAIL
      echo "Reply-To: $MAILFROM" >> $TMPMAIL
      echo "Subject: $MAILSUBJECT" >> $TMPMAIL
      echo "A new update is available for your system" >> $TMPMAIL
      echo "" >> $TMPMAIL
      echo "Currently you are running version $CVERSION the latest version is $LVERSION" >> $TMPMAIL
      echo "" >> $TMPMAIL
      echo "Please visit http://www.efa-project.org for more information." >> $TMPMAIL
      cat $TMPMAIL | $SENDMAIL -t
      rm $TMPMAIL
      exit 0
    else
      exit 0
  fi
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Function get latest version number
#----------------------------------------------------------------#
function get_version()
{
  cd /tmp
  if [ -f /tmp/EFA-version ]
    then
      rm /tmp/EFA-version
  fi

  wget -q $MIRROR1/update/EFA-version
  if [ -f /tmp/EFA-version ]
    then
      LVERSION="`head -1 /tmp/EFA-version`" 
  fi
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Check if we are root
#----------------------------------------------------------------#
function user_check()
{
  if [ `whoami` == root ]
    then
      echo "[EFA] Good you are root"
      start_update
  else
    echo "[EFA] Please become root to run this update"
    exit 0
  fi
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# show the usage
#----------------------------------------------------------------#
function show_usage()
{
  echo "Usage: $0 [option]"
  echo "Where [option] is:"
  echo ""
  echo "-update"
  echo "   Update to the latest version"
  echo ""
  echo "-check"
  echo "   check if there is a update available"
  echo ""
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Parse action
#----------------------------------------------------------------#
function parse_action()
{
  case $action in
      -update)
        user_check
        ;;
      -check)
        check_update
        ;;
      -cron)
        cron_check
        ;;
      *)
        show_usage
        ;;
  esac
  exit 0
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Main function
#----------------------------------------------------------------#
function main()
{
  if [ "X${action}" == "X" ]
    then
      show_usage
      exit 0
    else
      parse_action
  fi
}
#----------------------------------------------------------------#

#----------------------------------------------------------------#
# Run main
#----------------------------------------------------------------#
main
#----------------------------------------------------------------#