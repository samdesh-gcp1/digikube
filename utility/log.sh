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



	if [[ $# -lt 5 ]]; then
		echo "Error: ${__function_name} : Insufficient arguments provided: ${1}"
		exit 0
	else
		echo "its fun"
	fi
	
	
	option=${2}
	if [[ "${option}" = "init" ]]; then
		if [[ ${logConfig_init_logLevel -lt ${3} ]]; then
#			log_msg="$(date) : $1 : $3 : $4 : $5"
#			echo ${log_msg} >> ${init_log}
#			if [[ "${logConfig_init_logEcho}" = "on" ]]; then
#				echo ${log_msg}
#			fi
			echo "111111"
		fi
		echo "more fun"
	else
#		if [[ "${option}" = "installer" ]]; then
#			if [[ ${logConfig_installer_logLevel} -lt $3 ]]; then
#				log_msg="$(date) : $1 : $3 : $4 : $5"
#				echo ${log_msg} >> ${installer_log}
#				if [[ "${logConfig_installer_logEcho}" = "on" ]]; then
#					echo ${log_msg}
#	fi
#			fi
#		else
#			echo "Error: ${__function_name} : Unkwonk log type: ${option}"
#			exit 1
#		fi
		echo "even more fun"
	fi

	
	
}

echo "tets2"

