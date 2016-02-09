#!/bin/bash
########################################################################################
#
#       Filename: ds8870-lsarray.sh
#       Author: Matthew Mattox matt@mattox.work
#       Date: 12/18/2014
#       Purpose: Nagios Service Check to verify disk array status
#		Update: 07/01/2015 - Added B1DS88701 and SPHXDC88701 
#
########################################################################################

usage()
{
cat << EOF
usage: $0 options

Nagios Service Check to verify disk array status.

OPTIONS:
   -h      Show this message
   -S      ds8870 Name     			Example: chidc8870
EOF
}

while getopts .h:S:A:V.v. OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         S)
             DS8870NAME=$OPTARG
             ;;
         V)
             VERBOSE=1
             ;;
         v)
             VERBOSE=1
             ;;
         ?)
            usage
             exit
             ;;
     esac
done
if [[ -z $DS8870NAME ]]
then
        usage
        exit 1
fi

##Overview - start
if [ "$VERBOSE" = "1" ];
then
echo "########################################"
echo "DS8870 Name:" $DS8870NAME
echo "########################################"
read -p "Please press [Enter] to continue..."
fi
##Overview - end

CFG=""

if [ "$DS8870NAME" == "a1ds88701" ] || [ "$DS8870NAME" == "A1DS88701" ]
then
	DS8870NAME="A1DS88701"
	CFG="/opt/ibm/dscli/profile/A1DS88701.profile"
fi
if [ "$DS8870NAME" == "b1ds88701" ] || [ "$DS8870NAME" == "B1DS88701" ]
then
	DS8870NAME="B1DS88701.rss.hyatt.com"
        CFG="/opt/ibm/dscli/profile/B1DS88701.profile"
fi
if [ "$DS8870NAME" == "c1ds88701" ] || [ "$DS8870NAME" == "C1DS88701" ]
then
	DS8870NAME="B1DS88701.rss.hyatt.com"
        CFG="/opt/ibm/dscli/profile/C1DS88701.profile"
fi

if [ "$CFG" == "" ]
then	
	echo "Problem: Can not find DS8870"
	exit 1
fi

####Get array status - start
STATUS=$(/opt/ibm/dscli/dscli -cfg $CFG "lsarray -fmt delim -hdr off" | grep -v ",Normal,")
####Get array status - end

if [ "$VERBOSE" = "1" ];
then
echo "STATUS:" $STATUS
fi

if [[ -z "$STATUS" ]];
then
        echo "OK: All Array are Normal"
        exit 0
else
        echo "CRITICAL: Problem found with Array" $(echo $STATUS | grep -v ",Normal," | awk -F"," '{print $1}')
        exit 2
fi