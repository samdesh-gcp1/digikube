#!/bin/sh

cloud_type="${CLOUD_TYPE}"

if [ -z ${cloud_type} ]; then
	echo "Error: No cloud provider defined."
	exit 1
fi

case ${cloud_type} in
	"gce")	export BASTION_HOST_NAME="bastion-host-01"
		export BASTION_MACHINE_TYPE="f1-micro"
		export BASTION_NETWORK_TIER="STANDARD"
		export BASTION_PREEMPTIBLE="Yes"
		export BASTION_TAGS="bastion-host,http-server,https-server"
		export BASTION_IMAGE="ubuntu-1804-bionic-v20191211"
		export BASTION_IMAGE_PROJECT="ubuntu-os-cloud"
		export BASTION_BOOT_DISK_SIZE="10GB"
		export BASTION_BOOT_DISK_TYPE="pd-standard"
		export BASTION_LABELS="type=bastion-host"
		;;
	"aws")	echo "Comming soon..."
		exit 3
		;;
	*)	echo "Unknown cloud provider defined: ${cloud_type}"
		exit 4
		;;
esac


