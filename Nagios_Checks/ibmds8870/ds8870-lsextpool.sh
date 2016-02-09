#!/bin/bash
########################################################################################
#
#       Filename: ds8870-lsextpool.sh
#       Author: Matthew Mattox matt@mattox.work
#       Date: 02/03/2015
#       Purpose: Nagios Service Check to verify EXTPOOL status
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
   -A      ExtPool				Example: p0
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
         A)
             EXTPOOL=$OPTARG
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
echo "ExtPool:" $EXTPOOL
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

####Get array status - start
/opt/ibm/dscli/dscli -cfg $CFG "showextpool $EXTPOOL" > /tmp/ds8870-lsextpool--$DS8870NAME--$EXTPOOL
####Get array status - end

usedpercentage=$(cat /tmp/ds8870-lsextpool--$DS8870NAME--$EXTPOOL | grep  -w '^%allocated ' | awk '{print $2}')
usedgb=$(cat /tmp/ds8870-lsextpool--$DS8870NAME--$EXTPOOL | grep -w '^allocated' | awk '{print $2}')
freegb=$(cat /tmp/ds8870-lsextpool--$DS8870NAME--$EXTPOOL | grep -w '^available' | awk '{print $2}')
totalgb=$(cat /tmp/ds8870-lsextpool--$DS8870NAME--$EXTPOOL | grep -w '^configured' | awk '{print $2}')

if [[ "$VERBOSE" == "1" ]]; then
        echo "Pool ID:" $EXTPOOL
        echo "Used Percentage:" $usedpercentage
        echo "Used in GBs:" $usedgb
        echo "Free in GBs:" $freegb
        echo "Total in GBs:" $totalgb
fi

if [[ $usedpercentage -eq 95 ]];
then
        echo "CRITICAL: ExtPool" $EXTPOOL "has" $usedpercentage "% used | usedpercentage="$usedpercentage"% usedgb="$usedgb"GB freegb="$freegb"GB totalgb="$totalgb"GB"
        exit 2
fi

if [[ $usedpercentage -eq 90 ]];
then
        echo "WARNING: ExtPool" $EXTPOOL "has" $usedpercentage "% used | usedpercentage="$usedpercentage"% usedgb="$usedgb"GB freegb="$freegb"GB totalgb="$totalgb"GB"
        exit 1
fi

echo "OK: ExtPool" $EXTPOOL "is allocated at" $usedpercentage "% used | usedpercentage="$usedpercentage"% usedgb="$usedgb"GB freegb="$freegb"GB totalgb="$totalgb"GB"
exit 0
