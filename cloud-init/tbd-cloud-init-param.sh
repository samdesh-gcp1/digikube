#!/bin/sh

cloud_type="${CLOUD_TYPE}"

if [ -z ${cloud_type} ]; then
	echo "Error: No cloud provider defined."
	exit 1
fi

case ${cloud_type} in
	"gce")	export CLOUD_PROJECT="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
		if [ $? -gt 0 ]; then
			exit 1
		fi
		if [ -z ${CLOUD_PROJECT} ]; then
			echo "Error: Not able to get cloud project details."
			exit 2
		fi
		export CLOUD_SUBNET="${CLOUD_PROJECT}-vpc"
		export CLOUD_REGION="us-central1"
		export CLOUD_ZONE="us-central1-c"
		;;
	"aws")	echo "Comming soon..."
		exit 3
		;;
	*)	echo "Unknown cloud provider defined: ${cloud_type}"
		exit 4
		;;
esac


