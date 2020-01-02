#!/bin/sh

#Set your cloud type

if [ "$#" -eq 0 ] ; then
	echo "No argument supplied"
	exit 1
fi

option="${1}"
case ${option} in 
	"gce")	echo "Setting gce as the cloud provider."
		CLOUD_TYPE="gce"
		;;
  	"aws")	echo "Setting aws as the cloud provider."
		CLOUD_TYPE="aws"
		;;
	*)	echo "Unkwonk cloud provider: ${option}."
		exit 2
		;;
esac

echo "The set cloud provider is : $CLOUD_TYPE"

