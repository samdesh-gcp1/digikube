#!/bin/sh

export digikube_cloud_admin=$(whoami)

FLOW_OPTION_YES="yes"
FLOW_OPTION_NO="no"

DELETE_CLUSTER_COMMAND="~/digikube/cluster/digiops cluster delete"

BASTION_HOST_NAME="bastion-host-01"
export BASTION_HOST_ZONE=$(gcloud compute instances list --filter="name=${BASTION_HOST_NAME}" --format="value(zone)")
if [ $? -gt 0 ]; then
	echo "Unable to get the cloud zone details.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
fi
if [ -z ${BASTION_HOST_ZONE} ]; then
	echo "Unable to get the cloud zone details.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
fi

if [ $# -gt 0 ]; then
	FLOW_DELETE_CHOICE=$1
else
	if [ -z $FLOW_DELETE_CHOICE_ENV_VAR ]; then
		echo "No option specified for DigiKube deletion.  Exiting digikube deletion."
		exit 1
	else
		FLOW_DELETE_CHOICE=$FLOW_DELETE_CHOICE_ENV_VAR
	fi
fi

if [ -z $FLOW_DELETE_CHOICE ]; then
	echo "No option specified for DigiKube deletion.  Exiting digikube deletion."
	exit 1
else
	if [[ "$FLOW_DELETE_CHOICE" == "all-with-bucket" ]]; then
		FLOW_DELETE_BASTION_HOST=$FLOW_OPTION_YES
		FLOW_DELETE_BASTION_FIREWALL_RULE=$FLOW_OPTION_YES
		FLOW_DELETE_VPC=$FLOW_OPTION_YES
		FLOW_DELETE_BUCKET=$FLOW_OPTION_YES
	fi
	if [[ "$FLOW_DELETE_CHOICE" == "all" ]]; then
		FLOW_DELETE_BASTION_HOST=$FLOW_OPTION_YES
		FLOW_DELETE_BASTION_FIREWALL_RULE=$FLOW_OPTION_YES
		FLOW_DELETE_VPC=$FLOW_OPTION_YES
		FLOW_DELETE_BUCKET=$FLOW_OPTION_NO
	fi
	if [[ "$FLOW_DELETE_CHOICE" == "bastion-host" ]]; then
		FLOW_DELETE_BASTION_HOST=$FLOW_OPTION_YES
		FLOW_DELETE_BASTION_FIREWALL_RULE=$FLOW_OPTION_NO
		FLOW_DELETE_VPC=$FLOW_OPTION_NO
		FLOW_DELETE_BUCKET=$FLOW_OPTION_NO
	fi
fi

export CLOUD_TYPE="gce"

export CLOUD_REGION="us-central1"
export CLOUD_ZONE="us-central1-c"

echo
echo
echo "Removing cloud environemnt for DigiKube.  Cloud provider: gce."
echo

##########################################################
#Get cloud project details
export CLOUD_PROJECT="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
if [ $? -gt 0 ]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
fi
if [ -z ${CLOUD_PROJECT} ]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
else
	echo "Deleting DigiKube resources from cloud project.  Cloud project id: ${CLOUD_PROJECT}."
fi

##########################################################
#Get bastion host
IP=$(gcloud compute instances list --zones=$BASTION_HOST_ZONE | awk '/'$BASTION_HOST_NAME'/ {print $5}')
if nc -w 1 -z $IP 22; then
    echo "OK! Ready for heavy metal"
    
else
    gcloud compute instances start $BASTION_HOST_NAME --zones=$BASTION_HOST_ZONE
    IP=$(gcloud compute instances list --zones=$BASTION_HOST_ZONE | awk '/'$BASTION_HOST_NAME'/ {print $5}')
    if nc -w 1 -z $IP 22; then
    	echo "OK! Ready for heavy metal"
		
	else
		echo "Not able to access bastion host."
		exit 1
	fi
fi
echo "gcloud compute ssh $BASTION_HOST_NAME --zones=$BASTION_HOST_ZONE --command=${DELETE_CLUSTER_COMMAND}"
gcloud compute ssh $BASTION_HOST_NAME --zones=$BASTION_HOST_ZONE --command="${DELETE_CLUSTER_COMMAND}"


##########################################################
#Delete the Bastion Host for DigiKube
if [ "$FLOW_DELETE_BASTION_HOST" = "$FLOW_OPTION_YES" ]; then
	
	echo "Attempting to delete bastion host for Digikube.  Bastion host name: ${BASTION_HOST_NAME} in zone ${BASTION_HOST_ZONE}."
		
	if [ -z $(gcloud compute instances list --filter="name=${BASTION_HOST_NAME}" --format="value(name)") ]; then
  		echo "No bastion host available with the name ${BASTION_HOST_NAME}.  Skipping bastion host deletion."
	else
  		gcloud --quiet compute instances delete ${BASTION_HOST_NAME} --zone=${BASTION_HOST_ZONE}
  		if [ $? -gt 0 ]; then
    			#Unknown error while deleting the bastion host.
    			echo "Unable to delete bastion host for DigiKube.  Exiting the DigiKube delete."
    			echo "Manually review and delete DigiKube cloud resources."
    			exit 1
  		else
    			echo "Deleted the bastion host: ${BASTION_HOST_NAME}."
  		fi
	fi
else
	echo "Skipping bastion-host deletion."
fi

export CLOUD_SUBNET="${CLOUD_PROJECT}-vpc"

###########################################################
#Delete firewall rule for bastion host
if [ "$FLOW_DELETE_BASTION_FIREWALL_RULE" = "$FLOW_OPTION_YES" ]; then
	export BASTION_HOST_FIREWALL_RULE_NAME="${CLOUD_SUBNET}-allow-bastion-ssh"
	echo "Attempting to delete firewall rule for bastion host: ${BASTION_HOST_FIREWALL_RULE_NAME}"
	if [ -z $(gcloud compute firewall-rules list --filter=name=${BASTION_HOST_FIREWALL_RULE_NAME} --format="value(name)") ]; then
		echo "No firewall rule available with the name ${BASTION_HOST_FIREWALL_RULE_NAME}.  Skipping firewall rule deletion."
	else
		gcloud -q compute firewall-rules delete ${BASTION_HOST_FIREWALL_RULE_NAME}
		if [ $? -gt 0 ]; then
	    		#Unknown error while deleting the firewall rule.
	    		echo "Unable to delete firewall rule for bastion host.  Exiting the DigiKube delete."
	    		echo "Manually review and delete DigiKube cloud resources."
	    		exit 1
	  	else
	    		echo "Deleted the firewall rule for bastion host: ${BASTION_HOST_FIREWALL_RULE_NAME}."
		fi
	fi
else
	echo "Skipping bastion-host firewall rule deletion."
fi

###########################################################
#Delete the network for DigiKube
if [ "$FLOW_DELETE_VPC" = "$FLOW_OPTION_YES" ]; then
	echo "Attempting to delete network for Digikube.  Network name: ${CLOUD_SUBNET}."
	if [ -z $(gcloud compute networks list --filter=name=${CLOUD_SUBNET} --format="value(name)") ]; then
  		echo "No network available with the name ${CLOUD_SUBNET}.  Skipping network deletion."
	else
  		gcloud --quiet compute networks delete ${CLOUD_SUBNET}
	  	if [ $? -gt 0 ]; then
    			#Unknown error while deleting the network.
	    		echo "Unable to delete network for DigiKube.  Exiting the DigiKube delete."
    			echo "Manually review and delete DigiKube cloud resources."
	    		exit 1
  		else
    			echo "Deleted the network ${CLOUD_SUBNET}."
  		fi
	fi
else
	echo "Skipping vpc deletion."
fi

###########################################################
#Delete the storage bucket for DigiKube
if [ "$FLOW_DELETE_BUCKET" = "$FLOW_OPTION_YES" ]; then
	
	CLOUD_BUCKET="${digikube_cloud_admin}-${CLOUD_PROJECT}-bucket"
	BUCKET_URL="gs://${CLOUD_BUCKET}"
	echo "Attempting to delete bucket for Digikube.  Bucket name: ${CLOUD_BUCKET}."
	
	#Check if bucket already exists
	bucket_list=$(gsutil ls ${BUCKET_URL})
	if [[ $? -gt 0 ]]; then
		echo "INFO: You do not have any bucket with this name: ${CLOUD_BUCKET}.  Skipping bucket deletion."
	else
		gsutil rm -r ${BUCKET_URL}
		if [ $? -gt 0 ]; then
    			#Unknown error while deleting the bucket.
	    		echo "Unable to delete bucket for DigiKube.  Exiting the DigiKube delete."
    			echo "Manually review and delete DigiKube cloud resources."
	    		exit 1
  		else
    			echo "Deleted the bucket ${CLOUD_BUCKET}."
  		fi
	fi
else
	echo "Skipping bucket deletion."
fi
