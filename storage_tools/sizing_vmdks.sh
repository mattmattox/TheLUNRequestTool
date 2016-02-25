#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This tool is used to size VMDKs for Linux VMs using LVM.

OPTIONS:
   -h      Show this message
   -S      Size of Volgrp Example: 2000
EOF
}

while getopts .h:S:V.v. OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         S)
             VOLGRP=$OPTARG
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
if [[ -z "$VOLGRP" ]]; then
        echo "ERROR: Missing require arguments."
                echo "-S Size of Volgrp Example: 2000"
        exit 1
fi

if [[ "$VOLGRP" -lt 50 ]]
then
        echo "Size of VolGrp:" $VOLGRP
        echo "Number of VMDKs:" "1"
        echo "Size per VMDK:" "50"
        exit 0
fi


if [[ "$VOLGRP" -lt 100 ]]
then
        echo "Size of VolGrp:" $VOLGRP
        echo "Number of VMDKs:" "2"
        echo "Size per VMDK:" "50"
        exit 0
fi


VMDK_Size_Tmp=$(echo "$VOLGRP / 2" | bc)
SCSI_Devices='2'
if [[ "$VMDK_Size_Tmp" -gt 300 ]]
then
        VMDK_Size=$(echo "$VMDK_Size_Tmp / 2" | bc)
        SCSI_Devices=$(echo "$SCSI_Devices * 2" | bc)
        while [[ "$VMDK_Size" -gt 300 ]]
        do
                VMDK_Size=$(echo "$VMDK_Size / 2" | bc)
                SCSI_Devices=$(echo "$SCSI_Devices * 2" | bc)
                if [[ "$SCSI_Devices" -ge 32 ]]
                then
                        break
                fi
        done
else
        if [[ "$VMDK_Size_Tmp" -lt 50 ]]
        then
                VMDK_Size=$(echo "$VMDK_Size * 2" | bc)
                SCSI_Devices=$(echo "$SCSI_Devices / 2" | bc)
                while [[ "$VMDK_Size_Tmp" -lt 50 ]]
                do
                        VMDK_Size=$(echo "$VMDK_Size * 2" | bc)
                        SCSI_Devices=$(echo "$SCSI_Devices * 2" | bc)
                done
        else
                VMDK_Size="$VMDK_Size_Tmp"
        fi
fi

####Round up VMDK to the next 50GB
if [[ ! "$(echo ""$(echo "$VMDK_Size / 50" | bc)" * 50" | bc)" -eq "$VMDK_Size" ]]
then
        VMDK_Size="$(echo ""$(echo "$VMDK_Size / 50" | bc)" * 50 + 50" | bc)"
fi


echo "Size of VolGrp:" $VOLGRP
echo "Number of VMDKs:" $SCSI_Devices
echo "Size per VMDK:" $VMDK_Size
