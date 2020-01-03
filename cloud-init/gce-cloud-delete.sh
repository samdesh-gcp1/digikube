#!/bin/sh

echo
echo
echo "Removing cloud environemnt for DigiKube.  Cloud provider: gce."
echo

export CLOUD_TYPE="gce"

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

#Delete the VPC for DigiKube
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
