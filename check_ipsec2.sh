#!/bin/bash
#set -x
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# Based partially on the work done by By Nicole in the check_ipsec script
#
# Plugin Name: check_ipsec2
# Version: 0.2
# Date: 24/04/2013
#
# Usage: check_ipsec2 --tunnels <n>
#        check_ipsec2 --tunnel <tunnel name>
#
# gateways.txt file must be located in same directory
# and has to look like:
# nameofconn1	192.168.0.1
# nameofconn2	192.168.1.1
#
# ------------Defining Variables------------
PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0rc1"
GATEWAYLIST="/etc/nagios/ipsec_gateways.txt"
DOWN=""
AWKBIN=`which awk`
EGREPBIN=`which egrep`
FPINGBIN=`which fping`
GREPBIN=`which grep`
IPSECBIN=`which ipsec`
WCBIN=`which wc`
PINGIP=0

AUTHOR="Copyright 2013, Charles Williams (chuck@itadmins.net) (http://www.itadmins.net/)"

missing="O"

. $PROGPATH/utils.sh

print_version() {
    echo "$VERSION $AUTHOR"
}

print_usage() {
        echo "Usage:"
        echo " $PROGNAME [-hprsv] [-a number of connections] [-c IPSEC connection name]"
	echo "           -a <number of configured tunnels> (Check all connections)"
        echo "           -c <name of connection> (Check specific connection)"
	echo "           -p (Ping remote gateway. Used only with -c)"
	echo "           -r (Restart IPSEC if down)"
        echo "           -s (Reacquire SA for connection. Used only with both -c and -p)"
        echo "           -h (Show this help screen)"
        echo "           -v (Show version)"
	echo
	echo "-a and -c cannot be used together. -s can only be used with -c."
	echo "-p can only be used with -c."
		echo ""
}

print_help() {
        print_revision $PROGNAME $REVISION
        echo ""
        print_usage
        echo ""
}

if [ $# -eq 0 ];
then
   print_help
   exit $STATE_UNKNOWN
fi

test -e $IPSECBIN
if [ $? -ne 0 ];
then
	echo CRITICAL - $IPSECBIN not exist
	exit $STATE_CRITICAL
else
	STRONG=`$IPSECBIN --version |grep strongSwan | wc -l`
fi

check_all() {
	if [[ "$STRONG" -eq "1" ]]
	then
	    eroutes=`$IPSECBIN status | $EGREPBIN -e "INSTALLED, |IPsec SA established" | wc -l`
	else
	    eroutes=`$IPSECBIN whack --status | grep -e "IPsec SA established" | grep -e "newest IPSEC" | wc -l`
	fi

        #if [[ "$PINGIP" -eq "1" ]]
        #then
        #        ping_gateway $1
        #fi

	if [[ "$eroutes" -eq "$1" ]]
	then
		echo "OK - All $1 tunnels are up and running"
		exit $STATE_OK
	elif [[ "$eroutes" -gt "$1" ]]
	then
		echo "WARNING - More than $1 ($eroutes) tunnels are up and running"
                exit $STATE_WARNING
	else
		echo "CRITICAL - Only $eroutes tunnels from $1 are up and running."
		exit $STATE_CRITICAL
	fi
}

check_connection() {
	if [[ "$STRONG" -eq "1" ]]
	then
			eroutes=`$IPSECBIN status | grep -e "$1" | $EGREPBIN -e "INSTALLED, |IPsec SA established" | wc -l`
	else
			eroutes=`$IPSECBIN whack --status | grep -e "IPsec SA established" | grep -e "$2" | wc -l`
	fi

	if [[ "$PINGIP" -eq "1" ]]
	then
		ping_gateway $1
	fi

	if [[ "$eroutes" -eq "1" ]]
	then
		echo "OK - $1 Connection is up and running"
		exit $STATE_OK
	else
		if [[ "$REACQUIRE" -eq "1" ]]; then
			reacquire_sa $1
		elif [[ "$RESTART" -eq "1" ]]; then
			restart_ipsec
		else
			echo "CRITICAL - $1 Connection is down"
			exit $STATE_CRITICAL
		fi
	fi
}

ping_gateway() {
        GATEWAYIP=`$GREPBIN $1 $GATEWAYLIST| $AWKBIN '{print $2}'`
        PING=`$FPINGBIN $GATEWAYIP -r 1 | $GREPBIN alive | $WCBIN -l`

        if [[ "$PING" -eq "0" ]]
        then
                if [[ "$REACQUIRE" -eq "1" ]]; then
                        reacquire_sa $1
                else
 	               echo "CRITICAL - $1 is down (no ping)"
			exit $STATE_CRITICAL
		fi
        fi
}

restart_ipsec() {
	RETURN=`$IPSECBIN restart`
	echo "WARNING - IPSEC being restarted"
	exit $STATE_WARNING
}

reacquire_sa() {
	RETURN=`$IPSECBIN down $1; $IPSECBIN up $1`
	echo "WARNING - Connection $1 SA Updating"
	exit $STATE_WARNING
}

NUMCONN=""
CONNAME=""
CHECKALL=0
CHECKCON=0

while getopts ":a:c:prshv" opt; do
	case $opt in
		h)
        		print_help
		        exit $STATE_OK
        		;;
		v)
        		print_revision $PLUGIN $REVISION
	        	exit $STATE_OK
	        	;;
		a)
			NUMCONN=$OPTARG
			CHECKALL=1
			;;
		c)
			CONNAME=$OPTARG
			CHECKCON=1
			;;
		p)
			PINGIP=1
			;;
		r)
			RESTART=1
			;;
		s)
			REACQUIRE=1
			;;
		:)
			echo "Option -$OPTARG requires an arguement." >&2
			print_help
			exit $STATE_OK
			;;
		\?)
        		print_help
		        exit $STATE_OK
			;;
	esac
done

if [ $PINGIP -eq 1 ]
then
        test -e $GATEWAYLIST
        if [ $? -ne 0 ];
        then
           echo CRITICAL - $GATEWAYLIST does not exist
           exit $STATE_CRITICAL
        fi

        test -e $FPINGBIN
        if [ $? -ne 0 ];
        then
                echo CRITICAL - $FPINGBIN not installed or not found
                exit $STATE_CRITICAL
        fi
fi

if [[ ( $CONNAME = "" && $NUMCONN = "" ) || ( $CONNAME != "" && $NUMCONN != "" ) ]]; then
	print_help
        exit $STATE_OK
fi

if [ $CHECKCON -eq 1 ]; then
	check_connection $CONNAME
else
	check_all $NUMCONN
fi
