#!/bin/sh

echo "Setting gce as the cloud provider."

export CLOUD_TYPE="gce"

export CLOUD_PROJECT="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
if [ $? -gt 0 ]; then
	exit 1
fi
if [ -z ${CLOUD_PROJECT} ]; then
	echo "Error: Not able to get cloud project details."
	exit 1
fi

export CLOUD_SUBNET="${CLOUD_PROJECT}-vpc"
export CLOUD_REGION="us-central1"
export CLOUD_ZONE="us-central1-c"

export BASTION_HOST_NAME="bastion-host-01"
export BASTION_MACHINE_TYPE="f1-micro"
export BASTION_NETWORK_TIER="STANDARD"
export BASTION_PREEMPTIBLE="Yes"
export BASTION_TAGS="bastion-host,http-server,https-server"
export BASTION_IMAGE="ubuntu-1804-bionic-v20191211"
export BASTION_IMAGE_PROJECT="ubuntu-os-cloud"
export BASTION_BOOT_DISK_SIZE="10GB"
export BASTION_BOOT_DISK_TYPE="pd-standard"
export BASTION_LABELS="type=bastion-host"

#Create the VPC for DigiKube
echo "DigiKube setup: "
echo "Project: ${CLOUD_PROJECT}"
echo "Subnet: ${CLOUD_SUBNET}"

#gcloud compute networks create ${CLOUD_PROJECT}-vpc \
#        --project=${CLOUD_PROJECT} \
#        --subnet-mode=auto


