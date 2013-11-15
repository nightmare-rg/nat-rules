#!/bin/bash - 
### BEGIN INIT INFO
# Provides:          nat-rules
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: enable nat-rules for virtual machines
# Description:       This file must be used to add nat routing for all virtual machines
#
### END INIT INFO

#===============================================================================
#
#          FILE: nat-rules.sh
# 
#         USAGE: ./nat-rules.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jörg Stewig, 
#  ORGANIZATION: 
#       CREATED: 15.11.2013
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

#===============================================================================
#  GLOBAL DECLARATIONS
#===============================================================================

# VM Name	   VM1		     VM2		VM3	          VM4		
EXTERNAL_IP=('155.104.167.110' '155.104.167.111' '155.104.167.112' '155.104.167.113') 
INTERNAL_IP=('192.168.122.121' '192.168.122.140' '192.168.122.194' '192.168.122.195') 

#===============================================================================
#  FUNCTION DEFINITIONS
#===============================================================================

do_start ()
{
        
	index=0
	for external in "${EXTERNAL_IP[@]}"
	do
		internal=${INTERNAL_IP[$index]}

		iptables -t nat -A PREROUTING -d $external -j DNAT --to-destination $internal 
        	iptables -I FORWARD 1 -d $internal/32 -m state --state NEW -j ACCEPT
		
		let "index++" 

	done
	
}	# ----------  end of function do_start  ----------


do_stop ()
{
	index=0
	for external in "${EXTERNAL_IP[@]}"
	do
		internal=${INTERNAL_IP[$index]}

        	iptables -t nat -D PREROUTING -d $external -j DNAT --to-destination $internal
        	iptables -D FORWARD -d $internal/32 -m state --state NEW -j ACCEPT
		
		let "index++" 

	done
	
}	# ----------  end of function do_stop  ----------



case "$1" in
  start)
	echo "creating nat-rules.."
	do_start
	;;
  stop)
	echo "removing nat-rules.. "
	do_stop
	;;
 
  restart|force-reload)
	echo "Restarting nat-rules.. "
	do_stop
	sleep 1
	do_start
	;;
  *)
	echo "Usage: `basename $0` {start|stop|restart|force-reload}" >&2
	exit 3
	;;
esac    # --- end of case ---
