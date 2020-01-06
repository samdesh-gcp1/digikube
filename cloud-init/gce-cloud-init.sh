#!/bin/sh

export CLOUD_TYPE="gce"

export CLOUD_REGION="us-central1"
export CLOUD_ZONE="us-central1-c"

echo 
echo
echo "############################################"
echo "Using gce as the cloud provider for DigiKube."
echo

###################################################
#Get cloud project details
export CLOUD_PROJECT="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
if [ $? -gt 0 ]; then
	echo "Unable to get cloud project details for DigiKube.  Exiting DigiKube initialization."
	echo "Run the DigiKube delete scripts to clear partially created resources."
	exit 1
fi
if [ -z ${CLOUD_PROJECT} ]; then
	echo "Unable to get cloud project details for DigiKube.  Exiting DigiKube initialization."
	echo "Run the DigiKube delete scripts to clear partially created resources."
	exit 1
fi
echo "Cloud project to be used for DigiKube: ${CLOUD_PROJECT}."

###################################################
echo "Creating the DigiKube environment"

###################################################
#Create the VPC for DigiKube
export CLOUD_SUBNET="${CLOUD_PROJECT}-vpc"
echo "Attempting to create network: ${CLOUD_SUBNET}"

if [ -z $(gcloud compute networks list --filter=name=${CLOUD_SUBNET} --format="value(name)") ]; then
	gcloud compute networks create ${CLOUD_SUBNET} \
	       	--project=${CLOUD_PROJECT} \
        	--subnet-mode=auto
	if [ -z $(gcloud compute networks list --filter=name=${CLOUD_SUBNET} --format="value(name)") ]; then
		echo "Unable to create network for DigiKube.  Network name: ${CLOUD_SUBNET}. Exiting DigiKube initialization."
		echo "Run the DigiKube delete scripts to clear partially created resources."
		exit 1
	else
		echo "Created network for DigiKube.  Network name: ${CLOUD_SUBNET}."
	fi
else
	echo "Reusing the exiting network.  Network name: ${CLOUD_SUBNET}."
fi

####################################################
#Create bastion host for DigiKube
echo "Attempting to create bastion host: ${BASTION_HOST_NAME}"

export BASTION_HOST_NAME="bastion-host-01"
export BASTION_MACHINE_TYPE="f1-micro"
export BASTION_NETWORK_TIER="STANDARD"
export BASTION_PREEMPTIBLE="Yes"
export BASTION_TAG_IDENTIFIER="bastion-host"
export BASTION_TAGS="${BASTION_TAG_IDENTIFIER},http-server,https-server"
export BASTION_IMAGE="ubuntu-1804-bionic-v20191211"
export BASTION_IMAGE_PROJECT="ubuntu-os-cloud"
export BASTION_BOOT_DISK_SIZE="10GB"
export BASTION_BOOT_DISK_TYPE="pd-standard"
export BASTION_LABELS="type=${BASTION_TAG_IDENTIFIER},creator=cloud-init"
# export BASTION_INIT_SCRIPT=$(wget -q -O - https://github.com/samdesh-gcp1/digikube/raw/master/cloud-init/gce-bastion-host-init.sh)
export BASTION_INIT_SCRIPT='#! /bin/bash
			# Create a new file in home directory
			cd /home/samdesh_gcp1/
			touch test1.txt'
echo $BASTION_INIT_SCRIPT

if [ -z $(gcloud compute instances list --filter=name=${BASTION_HOST_NAME} --format="value(name)") ]; then
	
	gcloud beta compute instances create $BASTION_HOST_NAME \
        	--project=$CLOUD_PROJECT \
        	--zone=$CLOUD_ZONE \
        	--machine-type=$BASTION_MACHINE_TYPE \
        	--subnet=$CLOUD_SUBNET \
        	--network-tier=$BASTION_NETWORK_TIER \
        	--preemptible \
        	--scopes=https://www.googleapis.com/auth/cloud-platform \
        	--tags=$BASTION_TAGS \
        	--image=$BASTION_IMAGE \
        	--image-project=$BASTION_IMAGE_PROJECT \
        	--boot-disk-size=$BASTION_BOOT_DISK_SIZE \
        	--boot-disk-type=$BASTION_BOOT_DISK_TYPE \
        	--labels=$BASTION_LABELS \
		--metadata='$BASTION_INIT_SCRIPT'
#		--metadata startup-script='#! /bin/bash
#			# Create a new file in home directory
#			cd /home/samdesh_gcp1/
#			touch test1.txt'
	
	if [ -z $(gcloud compute instances list --filter=name=${BASTION_HOST_NAME} --format="value(name)") ]; then
		echo "Unable to create bastion host for DigiKube.  Bastion host name: ${BASTION_HOST_NAME}. Exiting DigiKube initialization."
		echo "Run the DigiKube delete scripts to clear partially created resources."
		exit 1
	else
		echo "Created bastion host for DigiKube.  Bastion host name: ${BASTION_HOST_NAME}."
	fi
else
	echo "Reusing the exiting bastion host.  Bastion host name: ${BASTION_HOST_NAME}."
fi

####################################################
#Create firewall rule to allow ssh to bastion host for DigiKube.

export BASTION_HOST_FIREWALL_RULE_NAME="${CLOUD_SUBNET}-allow-bastion-ssh"

echo "Attempting to create firewallrule for bastion host: ${BASTION_HOST_FIREWALL_RULE_NAME}"
if [ -z $(gcloud compute firewall-rules list --filter=name=${BASTION_HOST_FIREWALL_RULE_NAME} --format="value(name)") ]; then

	gcloud compute firewall-rules create ${BASTION_HOST_FIREWALL_RULE_NAME} \
		--project=${CLOUD_PROJECT} \
		--direction=INGRESS \
		--priority=1000 \
		--network=${CLOUD_SUBNET} \
		--action=ALLOW \
		--rules=tcp:22 \
		--source-ranges=0.0.0.0/0 \
		--target-tags=${BASTION_TAG_IDENTIFIER}
	
	if [ -z $(gcloud compute firewall-rules list --filter=name=${BASTION_HOST_FIREWALL_RULE_NAME} --format="value(name)") ]; then
		echo "Unable to create bastion host firewall rule for DigiKube.  Bastion host firewall rule name: ${BASTION_HOST_FIREWALL_RULE_NAME}. Exiting DigiKube initialization."
		echo "Run the DigiKube delete scripts to clear partially created resources."
		exit 1
	else
		echo "Created bastion host firewall rule for DigiKube.  Bastion host name: ${BASTION_HOST_FIREWALL_RULE_NAME}."
	fi	
		
else
	echo "Reusing the exiting bastion host firewall rule.  Bastion host firewall rule: ${BASTION_HOST_FIREWALL_RULE_NAME}."
fi
