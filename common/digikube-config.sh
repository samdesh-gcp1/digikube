#!/bin/bash

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh
. ${digi_dir}utility/cloud.sh


function export-digikube-config {
	# Get the DigiKube configuration

	__function_name="common/export-digikube-config"

	digikube_config=${digi_dir}config/digikube-config.yaml
	parse_yaml ${digikube_config} "__config_"

	log_it "${__function_name}" "installer" "DEBUG" "2110" "Exported the DigiKube configuration"
}

function validate-digikube-config {
	#Validate the digikube config against the current setup

	__function_name="common/validate-digikube-config"

	#Cloud provider
	#gce bellow to be replaced by dynamic cloud provider detection
	__cloud_provider="gce"
	if [[ "${__config_cloud_provider}" == "${__cloud_provider}" ]]; then
		local current_cloud_project=$(get-cloud-project 'gce')
		#local current_cloud_project="$(gcloud info |tr -d '[]' | awk '/project:/ {print $2}')"
		echo ${current_cloud_project}
		if [[ $? -gt 0 ]]; then
			log_it "${__function_name}" "installer" "ERR" "2110" "Not able to get project details."
			exit 1
		else
      		#Cloud project
  			if [[ "${__config_cloud_project_name}" == "${current_cloud_project}" ]]; then
      			#do nothing
      			temp1="1"
  			else
      			log_it "${__function_name}" "installer" "ERR" "2110" "Cloud project is not same as the one specified in config.  Exiting"
      			exit 1
  			fi
		fi
	else
		log_it "${__function_name}" "installer" "ERR" "2110" "Cloud provider is not same as the one specified in config.  Exiting"
		exit 1
	fi

	#Cloud admin user
	if [[ "${__config_cloud_adminUser}" == "$(whoami)" ]]; then
		#do nothing
		temp1="1"
	else
		log_it "${__function_name}" "installer" "ERR" "2110" "Cloud project is not same as the one specified in config.  Exiting"
		exit 1
	fi

	#VPC
	export __config_cloud_project_vpc="${__config_cloud_project_name}-vpc"

	#Bucket
	export __config_cloud_bucket_name="${__config_cloud_adminUser}-${__config_cloud_project_name}-${__config_cloud_bucket_nameSuffix}"

}


function get-config-value {

    __function_name="common/validate-digikube-config"
    local config_name=$(replace_substring "${1}" "." "_")
    config_name="__config_${config_name}"
    #log_it "${__function_name}" "installer" "DEBUG" "2110" "Config name : ${config_name}"
    if [[ -z ${config_name} ]]; then
        #log_it "${__function_name}" "installer" "ERR" "2110" "Invalid config $1"
        echo ""
    else
        local config_value="${!config_name}"
        #log_it "${__function_name}" "installer" "DEBUG" "2110" "Config value : ${config_value}"
        echo "${config_value}"
    fi
}

#Export the configuration as global
export-digikube-config
validate-digikube-config
