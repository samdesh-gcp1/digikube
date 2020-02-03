#!/bin/sh

DELETE_CLUSTER_COMMAND="~/digikube/cluster/digiops cluster delete"

#TO DO: Pickup the values from configuration.
cloud_type="gce"
cloud_region="us-central1"
cloud_zone="us-central1-c"
bastion_host_name="bastion-host-01"
digikube_cloud_admin=$(whoami)

bastion_host_zone=$(gcloud compute instances list --filter="name=${bastion_host_name}" --format="value(zone)")
__return_code=$?
if [[ ${__return_code} -gt 0 ]]; then
	echo "Unable to get the cloud zone details.  Exiting the Digikube delete."
	echo "Manually review and delete Digikube cloud resources."
	exit ${__return_code}
fi

if [[ -z ${bastion_host_zone} ]]; then
	echo "Unable to get the cloud zone details.  Exiting the Digikube delete."
	echo "Manually review and delete Digikube cloud resources."
	exit 1
fi

__command_param_count=$#
if [[ ${__command_param_count} -gt 0 ]]; then
	delete_choice=$1
else
	if [[ -z ${delete_choice} ]]; then
		echo "No option specified for Digikube deletion.  Exiting digikube deletion."
		exit 1
	fi
fi

__option="${delete_choice}"
case ${__option} in 
	"all-with-bucket")
		delete_cluster=true
		delete_bastion_host=true
		delete_bastion_firewall_rule=true
		delete_vpc=true
		delete_bucket=true
		;;
	"all")
		delete_cluster=true
		delete_bastion_host=true
		delete_bastion_firewall_rule=true
		delete_vpc=true
		delete_bucket=false
		;;
	"bastion-host")
		delete_cluster=true
		delete_bastion_host=true
		delete_bastion_firewall_rule=false
		delete_vpc=false
		delete_bucket=false
		;;
	"cluster")
		delete_cluster=true
		delete_bastion_host=false
		delete_bastion_firewall_rule=false
		delete_vpc=false
		delete_bucket=false
		;;
	*)
		echo "Unknown delete option: ${__option}.  Exiting."
		exit 1
esac

echo " "
echo " "
echo "Removing cloud environemnt for DigiKube.  Cloud provider: ${cloud_type}"
echo " "

##########################################################
#Get cloud project details
cloud_project="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
__return_code=$?
if [[ ${__return_code} -gt 0 ]]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit ${__return_code}
fi
if [[ -z ${cloud_project} ]]; then
	echo "Unable to get the project details for DigiKube.  Exiting the DigiKube delete."
	echo "Manually review and delete DigiKube cloud resources."
	exit 1
else
	echo "Deleting DigiKube resources from cloud project.  Cloud project id: ${cloud_project}."
fi

##########################################################
#Delete the Digikube k8s cluster
if [[ ${delete_cluster} ]]; then

	bastion_status=$(gcloud compute instances describe ${bastion_host_name} --zone=${bastion_host_zone} | grep "status: RUNNING")
	__return_code=$?
	if [[ ${__return_code} -gt 0 ]]; then
		echo "Error while checking the bastion host status.  Exiting the DigiKube delete."
		exit ${__return_code}
	fi
	if [[ "${bastion_status}" == "status: RUNNING" ]]; then
		echo "Bastion host available.  Tryining to delete cluster through bastion host."
	else
		#TO DO: Need to check for shutdown status.... currently assuming it is in shutdown status.
		gcloud compute instances start ${bastion_host_name} --zone=${bastion_host_zone}
		__return_code=$?
		if [[ ${__return_code} -gt 0 ]]; then
			echo "Error while starting bastion host.  Exiting the DigiKube delete."
			exit ${__return_code}
		fi
		bastion_status=$(gcloud compute instances describe ${bastion_host_name} --zone=${bastion_host_zone} | grep "status: RUNNING")
		__return_code=$?
		if [[ ${__return_code} -gt 0 ]]; then
			echo "Error while checking the bastion host status.  Exiting the DigiKube delete."
			exit ${__return_code}
		fi
		if [[ "${bastion_status}" == "status: RUNNING" ]]; then
			echo "Bastion host available.  Tryining to delete cluster through bastion host."
		else
			echo "Not able to access bastion host."
			exit 1
		fi
	fi
	
	echo "Attempting to delete Digikube K8S cluster."
	echo "gcloud compute ssh ${bastion_host_name} --zone=${bastion_host_zone} --command=${DELETE_CLUSTER_COMMAND}"
	gcloud compute ssh ${bastion_host_name} --zone=${bastion_host_zone} --command="${DELETE_CLUSTER_COMMAND}"
	__return_code=$?
	if [[ ${__return_code} -eq 0 ]]; then
		echo "Deleted the Digikube cluster."
	else
		if [[ ${__return_code} -eq 255 ]]; then
			echo "Error while performing ssh on bastion host."
			exit 255
		else
			echo "Error while deleting the Digikube cluster."
			exit ${__return_code}
		fi
	fi
fi

##########################################################
#Delete the Digikube bastion host
if [[ ${delete_bastion_host} ]]; then
	echo "Attempting to delete bastion host for Digikube.  Bastion host name: ${bastion_host_name} in zone ${bastion_host_zone}."
	if [[ -z $(gcloud compute instances list --filter="name=${bastion_host_name}" --format="value(name)") ]]; then
		#We are not exiting... will continue to next stage.
		echo "No bastion host available with the name ${bastion_host_name}.  Skipping bastion host deletion."
	else
		gcloud --quiet compute instances delete "${bastion_host_name}" --zone="${bastion_host_zone}"
		__return_code=$?
		if [[ ${__return_code} -gt 0 ]]; then
			#Unknown error while deleting the bastion host
			echo "Unable to delete bastion host for DigiKube.  Exiting the DigiKube delete."
			echo "Manually review and delete DigiKube cloud resources."
			exit ${__return_code}
		else
			echo "Deleted the bastion host: ${bastion_host_name}."
		fi
	fi
else
	echo "Skipping bastion-host deletion."
fi

###########################################################

cloud_subnet="${cloud_project}-vpc"

###########################################################
#Delete firewall rule for bastion host

if [[ ${delete_bastion_firewall_rule} ]]; then
	bastion_firewall_rule_name="${cloud_subnet}-allow-bastion-ssh"
	echo "Attempting to delete firewall rule for bastion host: ${bastion_firewall_rule_name}"
	if [[ -z $(gcloud compute firewall-rules list --filter=name=${bastion_firewall_rule_name} --format="value(name)") ]]; then
		echo "No firewall rule available with the name ${bastion_firewall_rule_name}.  Skipping firewall rule deletion."
	else
		gcloud -q compute firewall-rules delete ${bastion_firewall_rule_name}
		__return_code=$?
		if [[ ${__return_code} -gt 0 ]]; then
			#Unknown error while deleting the firewall rule.
	    		echo "Unable to delete firewall rule for bastion host.  Exiting the DigiKube delete."
	    		echo "Manually review and delete DigiKube cloud resources."
	    		exit ${__return_code}
	  	else
	    		echo "Deleted the firewall rule for bastion host: ${bastion_firewall_rule_name}."
		fi
	fi
else
	echo "Skipping bastion-host firewall rule deletion."
fi

###########################################################
#Delete the network for DigiKube
if [[ ${delete_vpc} ]]; then
	echo "Attempting to delete network for Digikube.  Network name: ${cloud_subnet}."
	if [[ -z $(gcloud compute networks list --filter=name=${cloud_subnet} --format="value(name)") ]]; then
  		echo "No network available with the name ${cloud_subnet}.  Skipping network deletion."
	else
  		gcloud --quiet compute networks delete ${cloud_subnet}
		__return_code=$?
		if [[ ${__return_code} -gt 0 ]]; then
	  		#Unknown error while deleting the network.
	    		echo "Unable to delete network for DigiKube.  Exiting the DigiKube delete."
    			echo "Manually review and delete DigiKube cloud resources."
	    		exit ${__return_code}
  		else
    			echo "Deleted the network ${cloud_subnet}."
  		fi
	fi
else
	echo "Skipping vpc deletion."
fi

###########################################################
#Delete the storage bucket for DigiKube
if [[ ${delete_bucket} ]]; then
	
	cloud_bucket="${digikube_cloud_admin}-${cloud_project}-bucket"
	bucket_url="gs://${cloud_bucket}"
	echo "Attempting to delete bucket for Digikube.  Bucket name: ${cloud_bucket}."
	
	#Check if bucket already exists
	bucket_list=$(gsutil ls ${bucket_url})
	__return_code=$?
	if [[ ${__return_code} -gt 0 ]]; then
		#TO DO: Specifically check if the bucket is not available or any other error... currently assuming bucket not available.
		echo "INFO: You do not have any bucket with this name: ${cloud_bucket}.  Skipping bucket deletion."
	else
		gsutil rm -r ${bucket_url}
		if [[ ${__return_code} -gt 0 ]]; then
			#Unknown error while deleting the bucket.
	    		echo "Unable to delete bucket for DigiKube.  Exiting the DigiKube delete."
    			echo "Manually review and delete DigiKube cloud resources."
	    		exit ${__return_code}
  		else
    			echo "Deleted the bucket ${cloud_bucket}."
  		fi
	fi
else
	echo "Skipping bucket deletion."
fi

###########################################################
echo "   "
echo "   "
echo "   "
echo "#####################################################"
echo "Deleted all resources for DigiKube."
echo "#####################################################"
echo "   "
echo "   "
echo "   "
