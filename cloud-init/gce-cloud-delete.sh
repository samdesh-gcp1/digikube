#!/bin/sh

echo "Removing cloud environemnt for DigiKube.  Cloud provider: gce."

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

#Delete the VPC for DigiKube
if [ -z $(gcloud compute networks list --filter=name=${CLOUD_SUBNET} --format="value(name)") ]; then
  echo "No network available with the name ${CLOUD_SUBNET}.  Skipping network deletion."
else
  gcloud --quiet compute networks delete ${CLOUD_SUBNET}
  if [ $? -gt 0 ]; then
    #Unknown error while deleting the network.
    exit 1
  else
    echo "Delete the network ${CLOUD_SUBNET}."
  fi
fi
