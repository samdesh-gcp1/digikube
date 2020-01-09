#!/bin/bash
# Log handling

local base_dir=~/
local log_dir=${base_dir}digikube-logs/
local init_log=${log_dir}digikube-init.log
local installer_log=${log_dir}digikube-installer.log

. 

function log_it {
    
    local __function_name="utility/log_it"
        
    if [ $# -lt 5 ]; then
        echo "Error: ($__function_name): Insufficient arguments provided: $1"
        exit 0      #Exit without error
    fi

    option="${2}"
    case ${option} in 
	    "init")         __log=${init_log}
                        ;;
  	    "installer")	__log=${installer_log}
                        ;;
	    *)	            echo "Error: ($__function_name): Unkwonk log type: ${option}"
		                exit 1
		                ;;
    esac
    
    local log_msg="$(date) : $1 : $3 : $4 : $5"
        >> ${__log}
    
}
