#!/bin/sh

#Set your cloud type

if [ "$#" -eq 0 ] ; then
	echo "No argument supplied"
	exit 1
fi

option="${1}"
case ${option} in 
	"gce")	echo "Setting gce as the cloud provider."
		export CLOUD_TYPE="gce"
		. ./cloud-init-param.sh
		if [ $? -gt 0 ]; then
			exit 1
		fi
		. ./bastion-host-param.sh
		if [ $? -gt 0 ]; then
			exit 1
		fi
		gce/gce-cloud-init.sh
		if [ $? -gt 0 ]; then
			exit 1
		fi
		;;
  	"aws")	echo "Setting aws as the cloud provider."
		export CLOUD_TYPE="aws"
		;;
	*)	echo "Unkwonk cloud provider: ${option}."
		exit 1
		;;
esac

#echo "The set cloud provider is : $CLOUD_TYPE"

