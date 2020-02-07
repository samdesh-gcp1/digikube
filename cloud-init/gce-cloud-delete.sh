#!/bin/sh
# Main script to delete the cloud resources.
# Input parameters
#	$1 => digikube code repository url
#	$2 => digikube config file (either url or local file)
#	$3 => command choice 
#		Only K8S Cluster									: cluster
#		K8S Cluster with bastion host						: bastion-host
#		K8S Cluster, bastion-host, cloud-resourses	    	: all
#		K8S Cluster, bastion-host, cloud-resources, bucket	: all-with-bucket

if [[ ${#} -lt 3 ]]; then
	echo "ERROR: Insufficient command parameters provided.  Exiting..."
	exit 1
fi

providedDigikubeCodeRawRepoUrl=${1}
providedDigikubeConfigFileRef=${2}
deleteChoice=${3}

DELETE_CLUSTER_COMMAND="~/digikube/cluster/digiops cluster delete"

#################################################################
# Some utility functions
#----------------------------------------------------------------

function isValidUrl {
	local __fnName="cloud-init/gce-cloud-delete.isValidUrl"
	regex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
	url="${1}"
	if [[ ${url} =~ ${regex} ]]; then 
    	return 0
	else
		return 1
    fi
}

function getConfigValue {
	value=$(echo ${digikubeJsonConfigSet} | jq ".${1}")
	echo "${value//\"/}"
}

function downloadFile {
	local __fnName="cloud-init/gce-cloud-delete.downloadFile"
	__fnMsg=""
	__fnErrMsg=""
	
	sourceUrl=${1}
	target=${2}
	isExecutable=${3}
	
	wget -q --no-cache -O "${target}" - ${sourceUrl}
	if [[ -f ${target} ]]; then
		if [[ "${isExecutable}" == "yes" ]]; then
			chmod +x ${target}
		fi
		__fnMsg="DEBUG: Successfully downloaded the file: ${sourceUrl} at ${target}."
		return 0
	else
		__fnErrMsg="ERROR: Not able to download file: ${sourceUrl} at ${target}."
		return 1
	fi
}

#################################################################
# Load pre-requisits
#----------------------------------------------------------------

# Directory to get all the files required for cloud initialization.
tmpExecDir=$(dirname $(realpath $0))
echo "INFO: Temporary execution directory is ${tmpExecDir}"

# Check the Digikube code repository url.
if [[ $(isValidUrl ${providedDigikubeCodeRawRepoUrl}) -gt 0 ]]; then
	echo "ERROR: Invalid Digikube repository url provided: ${providedDigikubeCodeRawRepoUrl}.  Exiting..."
	exit 1
else
	echo "INFO: Digikube code repository url is ${providedDigikubeCodeRawRepoUrl}"
fi

# Download and execute cloud-init/init-prep script
if [[ $(downloadFile "${providedDigikubeCodeRawRepoUrl}/cloud-init/init-prep" "${tmpExecDir}/init-prep" "yes") -gt 0 ]]; then
	echo ${__fnErrMsg}
	exit 1
else
	echo "INFO: Downloaded the init-prep script."
	if [[ $(${tmpExecDir}/init-prep ${providedDigikubeCodeRawRepoUrl}) -gt 0 ]]; then
		echo "ERROR: Error while running init-prep.  Exiting..."
		exit 1
	else
		echo "INFO: Successfully executed init-prep script."
	fi
fi

# Check the Digikube config file ref and download/copy the file to target location.
if [[ $(isValidUrl ${providedDigikubeConfigFileRef}) -gt 0 ]]; then
	if [[ -f ${providedDigikubeConfigFileRef} ]]; then
		# File available for Digikube config.
		cp ${providedDigikubeConfigFileRef} "${tmpExecDir}/${DIGIKUBE_BASE_CONFIG}"
		echo "INFO: Successfully coppied Digikube config file."
	else
		echo "ERROR: Invalid Digikube config file url or local file: ${providedDigikubeConfigFileRef}.  Exiting..."
		exit 1
	fi
else
	# Download the config/digikube-config.yaml file from url
	if [[ $(downloadFile "${providedDigikubeConfigFileRef}" "${tmpExecDir}/${DIGIKUBE_BASE_CONFIG}" "no") -gt 0 ]]; then
		echo ${__fnErrMsg}
		echo "ERROR: Error while downloading Digikube config file from url: ${providedDigikubeConfigFileRef}. Exiting..."
		exit 1
	else
		echo "INFO: Successfully downloaded Digikube config file."
	fi
fi

#################################################################
# Verify the config, perform pre-installation checks
#----------------------------------------------------------------

# Read and parse the config.yaml and populate json config set
digikubeJsonConfigSet=$(cat "${tmpExecDir}/${DIGIKUBE_BASE_CONFIG}" | yaml2json)
echo "INFO: Digikube json config set is ${digikubeJsonConfigSet}"

#----------------------------------------------------------------
# Check 1: Check if the git Digikube code repo matches
digikubeCodeRawRepoUrl=$(getConfigValue "gitConfig.digikubeCode.rawRepoUrl")
if [[ -z ${digikubeCodeRawRepoUrl} ]]; then
	echo "ERROR: Digikube git raw repo url not specified in config.  Exiting..."
	exit 1
else
	if [[ "${digikubeCodeRawRepoUrl}" != "${providedDigikubeCodeRawRepoUrl}" ]]; then
		echo "ERROR: The provided Digikube code repo url (${providedDigikubeCodeRawRepoUrl}) is not same as the one set in config (${digikubeCodeRawRepoUrl}).  Exiting..."
		exit 1
	fi
fi

#----------------------------------------------------------------
# Check 2: Check if cloud provider
digikubeCloudProvider=$(getConfigValue "cloud.provider")
if [[ -z ${digikubeCloudProvider} ]]; then
	echo "ERROR: Cloud provider not specified in config.  Exiting..."
	exit 1
else
	# TO DO: This has to be restructured for each of the cloud provider.
	if [[ "${digikubeCloudProvider}" != "gce" ]] && [[ "${digikubeCloudProvider}" != "aws" ]] && [[ "${digikubeCloudProvider}" != "azure" ]]; then
		echo "ERROR: Invalid cloud provider (${digikubeCloudProvider}) specified in config.  Exiting..."
		exit 1
	fi
fi
currentCloudProvider="gce"			#TO DO: Auto detect current cloud provider
if [[ "${currentCloudProvider}" == "${digikubeCloudProvider}" ]]; then
	echo "INFO: Using ${digikubeCloudProvider} as the cloud provider for Digikube."
else
	echo "ERROR: Current cloud provider (${currentCloudProvider}) is not same as the name set in config (${digikubeCloudProvider}).  Exiting..."
	exit 1
fi

#----------------------------------------------------------------
# Check 2: Verify the mandatory config values
# TO DO: Verify other config values.


#----------------------------------------------------------------
# Check 3: Check if admin users are same.
digikubeCloudAdminUser=$(getConfigValue "cloud.adminUser")
if [[ -z ${digikubeCloudAdminUser} ]]; then
	echo "ERROR: Cloud admin user not specified in config.  Exiting..."
	exit 1
else
	currentCloudAdminUser=$(whoami)
	if [[ "${currentCloudAdminUser}" == "${digikubeCloudAdminUser}" ]]; then
		echo "INFO: Using ${digikubeCloudAdminUser} identity for installing Digikube."
	else
		echo "ERROR: Current user (${currentCloudAdminUser}) is not same as the name set in config (${digikubeCloudAdminUser}).  Exiting..."
		exit 1
	fi
fi

#----------------------------------------------------------------
# Check 4: Check if the cloud project ids match
digikubeCloudProjectId=$(getConfigValue "cloud.project.id")
if [[ -z ${digikubeCloudProjectId} ]]; then
	echo "ERROR: Cloud project id not specified in config.  Exiting..."
	exit 1
else
	currentCloudProjectId="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"  # TO DO: Leverage cloud utility script for getting current cloud project.
	if [[ ${?} -gt 0 ]] || [[ -z ${currentCloudProjectId} ]] ; then
		echo "ERROR: Unable to get current cloud project details.  Exiting..."
		exit 1
	fi
	if [[ "${currentCloudProjectId}" == "${digikubeCloudProjectId}" ]]; then
		echo "INFO: Using ${digikubeCloudProjectId} as the project id for Digikube."
	else
		echo "ERROR: Current cloud project id (${currentCloudProjectId}) do not match with the value set in config (${digikubeCloudProjectId}).  Exiting..."
		exit 1
	fi
fi

#----------------------------------------------------------------
# Check 5: Check if the cloud project region specified
digikubeCloudProjectRegion=$(getConfigValue "cloud.project.region")
if [[ -z ${digikubeCloudProjectRegion} ]]; then
	echo "ERROR: Cloud project region not specified in config.  Exiting..."
	exit 1
else
	# TO DO: Validate if the cloud region is valid for the cloud provider selected.
	echo "INFO: Using ${digikubeCloudProjectRegion} as the default region for Digikube."
fi

#----------------------------------------------------------------
# Check 6: Check if the cloud project zone specified
digikubeCloudProjectZone=$(getConfigValue "cloud.project.zone")
if [[ -z ${digikubeCloudProjectZone} ]]; then
	echo "ERROR: Cloud project zone not specified in config.  Exiting..."
	exit 1
else
	# TO DO: Validate if the cloud zone is valid for the cloud provider selected.  Also check if the zone corresponds to the region selected.
	echo "INFO: Using ${digikubeCloudProjectZone} as the default zone for Digikube."
fi

#----------------------------------------------------------------
# Check 7: Validate cluster name
digikubeClusterIdentityNamePrefix=$(getConfigValue "cluster.identity.namePrefix")
if [[ -z ${digikubeClusterIdentityNamePrefix} ]]; then
	echo "ERROR: Cluster identity name prefix not specified in config.  Exiting..."
	exit 1
fi
digikubeClusterIdentityEnv=$(getConfigValue "cluster.identity.env")
if [[ -z ${digikubeClusterIdentityEnv} ]]; then
	echo "ERROR: Cluster identity environment not specified in config.  Exiting..."
	exit 1
fi
digikubeClusterIdentityDomain=$(getConfigValue "cluster.identity.domain")
if [[ -z ${digikubeClusterIdentityDomain} ]]; then
	echo "ERROR: Cluster identity domain not specified in config.  Exiting..."
	exit 1
fi
digikubeClusterFullName="${digikubeClusterIdentityNamePrefix}-${digikubeClusterIdentityEnv}-${digikubeCloudProjectId}.${digikubeClusterIdentityDomain}"
echo " "
read -p "Please confirm if the Digikube environment for cluster ${digikubeClusterFullName} is to be deleted (y/n): " confirmation
if [[ "${confirmation}" == "y" ]]; then
	echo "INFO: Attempting to delete the Digikube environment for cluster ${digikubeClusterFullName}"
else
	echo "INFO: Aborting the Digikube environment deletion"
fi

#----------------------------------------------------------------
# Check 7: Check bucket config
digikubeCloudBucketClass=$(getConfigValue "cloud.bucket.class")
if [[ -z ${digikubeCloudBucketClass} ]]; then
	echo "ERROR: Cloud bucket class not specified in config.  Exiting..."
	exit 1
else
	if [[ "${digikubeCloudBucketClass}" != "STANDARD" ]] && [[ "${digikubeCloudBucketClass}" != "PREMIUM" ]]; then
		echo "ERROR: Invalid cloud bucket class (${digikubeCloudBucketClass}) specified in config.  Exiting..."
		exit 1
	fi
fi

#----------------------------------------------------------------
# Check 8: Check bastion host config
digikubeBastionHostName=$(getConfigValue "cloud.bastionHost.name")
echo "INFO: Bastion host name is ${digikubeBastionHostName}"
if [[ -z ${digikubeBastionHostName} ]]; then
	echo "ERROR: Bastion host name not specified in config.  Exiting..."
	exit 1
else
	# TO DO: Verify the correctness of the following config values for bastion host.
	digikubeBastionHostMachineType=$(getConfigValue "cloud.bastionHost.machineType")
	echo "INFO: Bastion host machine type is ${digikubeBastionHostMachineType}"
	digikubeBastionHostNetworkTier=$(getConfigValue "cloud.bastionHost.networkTier")
	echo "INFO: Bastion host network tier is ${digikubeBastionHostNetworkTier}"
	digikubeBastionHostPreemptible=$(getConfigValue "cloud.bastionHost.preemptible")
	echo "INFO: Bastion host preemptibility is ${digikubeBastionHostPreemptible}"
	digikubeBastionHostTagIdentifier=$(getConfigValue "cloud.bastionHost.tagIdentifier")
	echo "INFO: Bastion host tag identifier is ${digikubeBastionHostTagIdentifier}"
	digikubeBastionHostTags="${digikubeBastionHostTagIdentifier},http-server,https-server"
	echo "INFO: Bastion host tags are ${digikubeBastionHostTags}"
	digikubeBastionHostImage=$(getConfigValue "cloud.bastionHost.image")
	echo "INFO: Bastion host image is ${digikubeBastionHostImage}"
	digikubeBastionHostImageProject=$(getConfigValue "cloud.bastionHost.imageProject")
	echo "INFO: Bastion host image project is ${digikubeBastionHostImageProject}"
	digikubeBastionHostBootDiskSize=$(getConfigValue "cloud.bastionHost.bootDiskSize")
	echo "INFO: Bastion host boot disk size is ${digikubeBastionHostBootDiskSize}"
	digikubeBastionHostBootDiskType=$(getConfigValue "cloud.bastionHost.bootDiskType")
	echo "INFO: Bastion host boot disk type is ${digikubeBastionHostBootDiskType}"
	digikubeBastionHostLabels="type=${digikubeBastionHostTagIdentifier},creator=digikube"
	echo "INFO: Bastion host labels are ${digikubeBastionHostLabels}"
fi

#################################################################
# Start deletion
#----------------------------------------------------------------

case ${deleteChoice} in 
	"all-with-bucket")
		deleteCluster="yes"
		deleteK8sRoutes="yes"
		deleteNodeportFirewallRule="yes"
		deleteBastionHost="yes"
		deleteBastionFirewallRule="yes"
		deleteSubnet="yes"
		deleteBucket="yes"
		;;
	"all")
		deleteCluster="yes"
		deleteK8sRoutes="yes"
		deleteNodeportFirewallRule="yes"
		deleteBastionHost="yes"
		deleteBastionFirewallRule="yes"
		deleteSubnet="yes"
		deleteBucket="no"
		;;
	"bastion-host")
		deleteCluster="yes"
		deleteK8sRoutes="yes"
		deleteNodeportFirewallRule="yes"
		deleteBastionHost="yes"
		deleteBastionFirewallRule="yes"
		deleteSubnet="no"
		deleteBucket="no"
		;;
	"cluster")
		deleteCluster="yes"
		deleteK8sRoutes="yes"
		deleteNodeportFirewallRule="yes"
		deleteBastionHost="no"
		deleteBastionFirewallRule="no"
		deleteSubnet="no"
		deleteBucket="no"
		;;
	*)
		echo "Unknown delete option: ${deleteChoice}.  Exiting Digikube delete."
		exit 1
esac

# Delete Digikube k8s cluster
# ===========================

if [[ "${delete_cluster}" = "yes" ]]; then

	bastionStatus=$(gcloud compute instances describe ${digikubeBastionHostName} --zone=${digikubeCloudProjectZone} | grep "status: RUNNING")
	__returnCode=$?
	if [[ ${__returnCode} -gt 0 ]]; then
		echo "Error while checking the bastion host status.  Exiting the Digikube delete."
		exit ${__returnCode}
	fi
	if [[ "${bastionStatus}" == "status: RUNNING" ]]; then
		echo "Tryining to delete cluster through bastion host (${digikubeBastionHostName})"
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
			#exit 1
			echo "Hi"
		fi
	fi
	
	echo "Attempting to delete Digikube K8S cluster."
	echo "gcloud compute ssh ${bastion_host_name} --zone=${bastion_host_zone} --command=${DELETE_CLUSTER_COMMAND}"
	gcloud --quiet compute ssh ${bastion_host_name} --zone=${bastion_host_zone} --command="${DELETE_CLUSTER_COMMAND}"
	__return_code=$?
	if [[ ${__return_code} -eq 0 ]]; then
		echo "Deleted the Digikube cluster."
	else
		if [[ ${__return_code} -eq 255 ]]; then
			echo "Error while performing ssh on bastion host."
			exit 255
		else
			echo "Error while deleting the Digikube cluster."
			#exit ${__return_code}
		fi
	fi
fi



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
#Delete firewall rule for nodeport

if [[ ${delete_nodeport_firewall_rule} ]]; then
	nodeport_firewall_rule_name="${cloud_subnet}-allow-external-to-nodeport"
	echo "Attempting to delete firewall rule for nodeport: ${nodeport_firewall_rule_name}"
	if [[ -z $(gcloud compute firewall-rules list --filter=name=${nodeport_firewall_rule_name} --format="value(name)") ]]; then
		echo "No firewall rule available with the name ${nodeport_firewall_rule_name}.  Skipping firewall rule deletion."
	else
		gcloud -q compute firewall-rules delete ${nodeport_firewall_rule_name}
		__return_code=$?
		if [[ ${__return_code} -gt 0 ]]; then
			#Unknown error while deleting the firewall rule.
	    		echo "Unable to delete firewall rule for nodeport.  Exiting the DigiKube delete."
	    		echo "Manually review and delete DigiKube cloud resources."
	    		exit ${__return_code}
	  	else
	    		echo "Deleted the firewall rule for nodeport: ${nodeport_firewall_rule_name}."
		fi
	fi
else
	echo "Skipping nodeport firewall rule deletion."
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
