#!/bin/bash
# Get the DigiKube configuration

__function_name="common/export-digikube-config.sh"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh

digikube_config=${digi_dir}config/digikube-config.yaml
parse_yaml ${digikube_config} "__config_"

log_it "${__function_name}" "installer" "DEBUG" "2110" "Exported the DigiKube configuration"
