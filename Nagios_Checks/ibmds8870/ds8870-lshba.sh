#!/bin/bash
########################################################################################
#
#       Filename: ds8870-lshba.sh
#       Author: Matthew Mattox matt@mattox.work
#       Date: 02/03/2015
#       Purpose: Nagios Service Check to verify HBA status
#       Update: Updated to include the CFG files.
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
   -D      Device ID                            Example: IBM.2107-75BMP51
EOF
}

while getopts .h:S:D:V.v. OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         S)
             DS8870NAME=$OPTARG
             ;;
         D)
             DEVID=$OPTARG
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
echo "Dev ID:" $DEVID
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
	DS8870NAME="B1DS88701"
        CFG="/opt/ibm/dscli/profile/B1DS88701.profile"
fi
if [ "$DS8870NAME" == "c1ds88701" ] || [ "$DS8870NAME" == "C1DS88701" ]
then
	DS8870NAME="C1DS88701"
    CFG="/opt/ibm/dscli/profile/C1DS88701.profile"
fi

DEVID=$(cat $CFG | grep ^devid | awk '{print $2}')

if [ "$VERBOSE" = "1" ];
then
	echo "##############################"
	echo "RAW DATA"
	/opt/ibm/dscli/dscli -cfg $CFG "lshba -fmt delim -hdr off $DEVID"
	echo "##############################"
fi
####Get array status - start
STATUS=$(/opt/ibm/dscli/dscli -cfg $CFG "lshba -fmt delim -hdr off $DEVID" | grep -v "Online")
####Get array status - end

if [[ -z "$STATUS" ]];
then
	echo "OK: All Disks storage image host adapters are Online"
        exit 0
else
	echo "CRITICAL: Problem found with storage image host adapters" $(echo $STATUS | grep -v "Online" | awk -F"," '{print $1}')
        exit 2
fi
