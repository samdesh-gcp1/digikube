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
parse_yaml "${log_config}" ""

log_it() {

	local __function_name="utility/log_it"

	if [[ $# -lt 5 ]]; then
		echo "Error: ${__function_name} : Insufficient arguments provided: ${1}"
		exit 0	
	fi

	case ${3} in 
		"DEBUG")	
			log_level=0
			level_msg="DEBUG"
			;;
		"INFO")
			log_level=2
			level_msg="INFO"
			;;
		"WARN")
			log_level=4
			level_msg="WARN"
			;;
		"ERR")
			log_level=6
			level_msg="ERROR"
			;;
		"FATAL")
			log_level=8
			level_msg="FATAL"
			;;
		*)
			log_level=10
			level_msg="UNKNOWN"
	esac
	
	case ${2} in
		"init")
			if [[ ${log_level} -lt ${logConfig_init_logLevel} ]]; then
				#Do nothing
				temp1=1
			else
				log_msg="$(date) : $1 : ${level_msg} : $4 : $5"
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
				log_msg="$(date) : $1 : ${level_msg} : $4 : $5"
				echo ${log_msg} >> ${installer_log}
				if [[ "${logConfig_installer_logEcho}" = "on" ]]; then
					echo ${log_msg}
				fi
			fi
			;;
		*)
			echo "$(date) : ${__function_name} : ERROR   : 0000 : Unkwonk log type: ${2}"
	esac
}
