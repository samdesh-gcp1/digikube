#!/bin/bash
# Log handling

base_dir=~/
log_dir=${base_dir}digikube-logs/
digi_dir=${base_dir}digikube/
log_config=${digi_dir}config/log-config.yaml
init_log=${log_dir}digikube-init.log
installer_log=${log_dir}digikube-installer.log

. ${digi_dir}utility/general.sh
eval $(parse_yaml ${log_config} )
echo "logConfig_installer_logLevel > ${logConfig_installer_logLevel}"
echo "logConfig_installer_logEcho > ${logConfig_installer_logEcho}"

echo "test"

log_it() {

	local __function_name="utility/log_it"
	echo "inside ${__function_name}"

}

echo "tets2"

