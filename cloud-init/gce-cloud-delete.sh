#!/bin/sh

export CLOUD_TYPE="gce"

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

echo
echo
echo "Removing cloud environemnt for DigiKube.  Cloud provider: gce."
echo

export CLOUD_PROJECT="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
if [ $? -gt 0 ]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete.
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
fi
if [ -z ${CLOUD_PROJECT} ]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete.
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
else
	echo "Deleting DigiKube resources from cloud project.  Cloud project id: ${CLOUD_PROJECT}."
fi

#Delete the Bastion Host for DigiKube
echo "Attempting to delete bastion host for Digikube.  Bastion host name: ${BASTION_HOST_NAME}."
if [ -z $(gcloud compute instances list --filter=name=${BASTION_HOST_NAME} --format="value(name)") ]; then
  echo "No bastion host available with the name ${BASTION_HOST_NAME}.  Skipping bastion host deletion."
else
  gcloud --quiet compute instances delete ${BASTION_HOST_NAME}
  if [ $? -gt 0 ]; then
    #Unknown error while deleting the bastion host.
    echo "Unable to delete bastion host for DigiKube.  Exiting the DigiKube delete.
    echo "Manually review and delete DigiKube cloud resources."
    exit 1
  else
    echo "Deleted the bastion host: ${BASTION_HOST_NAME}."
  fi
fi

#Delete the network for DigiKube
export CLOUD_SUBNET="${CLOUD_PROJECT}-vpc"
echo "Attempting to delete network for Digikube.  Network name: ${CLOUD_SUBNET}."
if [ -z $(gcloud compute networks list --filter=name=${CLOUD_SUBNET} --format="value(name)") ]; then
  echo "No network available with the name ${CLOUD_SUBNET}.  Skipping network deletion."
else
  gcloud --quiet compute networks delete ${CLOUD_SUBNET}
  if [ $? -gt 0 ]; then
    #Unknown error while deleting the network.
    echo "Unable to delete network for DigiKube.  Exiting the DigiKube delete.
    echo "Manually review and delete DigiKube cloud resources."
    exit 1
  else
    echo "Deleted the network ${CLOUD_SUBNET}."
  fi
fi
