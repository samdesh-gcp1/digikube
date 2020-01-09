#!/bin/bash
# Log handling

base_dir=~/
log_dir=${base_dir}digikube-logs/
digi_dir=${base_dir}digikube/
log_config=${digi_dir}config/log-config.yaml
init_log=${log_dir}digikube-init.log
installer_log=${log_dir}digikube-installer.log

. ${digi_dir}utility/general.sh
eval $(parse_yaml $log_config )
echo "logConfig_installer_logLevel > $logConfig_installer_logLevel"
echo "logConfig_installer_logEcho > $logConfig_installer_logEcho"

#Critical=4
#Error=3
#Warning=2
#Information=1
#Debug=0

	
function log_it {
    
    local __function_name="utility/log_it"
    
    echo "inside $__function_name"
    
    if [ $# -lt 5 ]; then
        echo "Error: ($__function_name): Insufficient arguments provided: $1"
        exit 0      #Exit without error
    fi

    option="${2}"
    case ${option} in 
	
	    "init")         if [[ $log-config_init_log-level -lt $3 ]]; then
							log_msg="$(date) : $1 : $3 : $4 : $5"
							echo $log_msg >> ${init_log}
							if [[ $log-config_init_log-echo == "on" ]]; then
								echo $log_msg
							fi
						fi
                        ;;
						
  	    "installer")	if [[ $log-config_installer_log-level -lt $3 ]]; then
							log_msg="$(date) : $1 : $3 : $4 : $5"
							echo $log_msg >> ${installer_log}
							if [[ $log-config_installer_log-echo == "on" ]]; then
								echo $log_msg
							fi
						fi
                        ;;
	
	    *)	            echo "Error: ($__function_name): Unkwonk log type: ${option}"
		                exit 1
		                ;;
    esac
      
}
