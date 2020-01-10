#!/bin/bash
# Log handling

base_dir=~/
log_dir=${base_dir}digikube-logs/
digi_dir=${base_dir}digikube/
log_config=${digi_dir}config/log-config.yaml
init_log=${log_dir}init.log
installer_log=${log_dir}installer.log
touch ${init_log}
touch ${installer_log}

. ${digi_dir}utility/general.sh
eval $(parse_yaml ${log_config} )

echo "logConfig_installer_logLevel > ${logConfig_installer_logLevel}"
echo "logConfig_installer_logEcho > ${logConfig_installer_logEcho}"

log_it() {

	local __function_name="utility/log_it"

	if [[ $# -lt 5 ]]; then
		echo "Error: ${__function_name} : Insufficient arguments provided: ${1}"
		exit 0	
	fi

	case ${3} in 
		"DEBUG")	
			log_level=0
			;;
		"INFO")
			log_level=2
			;;
		"WORN")
			log_level=4
			;;
		"ERR")
			log_level=6
			;;
		"FATAL")
			log_level=8
			;;
		*)
			log_level=10
	esac
	
	case ${2} in
		"init")
			if [[ ${log_level} -lt ${logConfig_init_logLevel} ]]; then
				#Do nothing
				temp1=1
			else
				log_msg="$(date) : $1 : $3 : $4 : $5"
				echo ${log_msg} >> ${init_log}
				if [[ "${logConfig_init_logEcho}" = "on" ]]; then
					echo ${log_msg}
				fi
			fi
			;;
		"installer")
			if [[ ${log_level} -lt ${logConfig_installer_logLevel} ]]; then
				#Do nothing
				temp1=1
			else
				log_msg="$(date) : $1 : $3 : $4 : $5"
				echo ${log_msg} >> ${installer_log}
				if [[ "${logConfig_installer_logEcho}" = "on" ]]; then
					echo ${log_msg}
				fi
			fi
			;;
		*)
			echo "$(date) : ${__function_name} : ERR : 0000 : Unkwonk log type: ${2}"
	esac
}
