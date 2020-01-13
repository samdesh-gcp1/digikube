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

#Cloud project
  if [[ "${__config_cloud.provider.project}" = "$(get-cloud-project 'gce'") ]]; then
      'do nothing
      temp1="1"
  else
      log_it "${__function_name}" "installer" "ERR" "2110" "Cloud project is not same as the one specified in config.  Exiting"
      exit 1
  fi
  
#Add others

}


function get-config-value {

    __function_name="common/validate-digikube-config"

    private config_name="__config_$(replace_substring $1 '.' '_')"
    if [[ -z ${config_name} ]]; then
        log_it "${__function_name}" "installer" "ERR" "2110" "Invalid config $1"
        return ""
    else
        return ${config_name}
    fi 
}

#Export the configuration as global
export-digikube-config
