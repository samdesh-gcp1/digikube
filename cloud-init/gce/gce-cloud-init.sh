#!/bin/sh

#Create gce cloud environment
#Prerequisit: Credentials and Project already available
#Creates VPC, Bastion Host and Bucket
#Relies on parameters set earlier

if [ -z ${CLOUD_PROJECT} ] || [ -z ${CLOUD_SUBNET} ]; then
	exit 1
fi

#Create the VPC for DigiKube
echo "DigiKube setup: "
echo "Project: ${CLOUD_PROJECT}"
echo "Subnet: ${CLOUD_SUBNET}"

#gcloud compute networks create ${CLOUD_PROJECT}-vpc \
#        --project=${CLOUD_PROJECT} \
#        --subnet-mode=auto
