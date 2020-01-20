#!/bin/bash
# kops installer

__function_name="installer/kops-installer.sh"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh

digikube_config=${digi_dir}config/digikube-config.yaml
parse_yaml ${digikube_config} "__config_"

log_it "${__function_name}" "installer" "INFO" "1210" "Started the kops installation process"

kopsn_installer=${digi_dir}installer/kopsn-installer.sh
${kopsn_installer}
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" "ERR" "1225" "Error while kops-n installation.  Exiting"
    Exit 1
fi

kopsp_installer=${digi_dir}installer/kopsp-installer.sh
${kopsp_installer}
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" "ERR" "1225" "Error while kops-p installation.  Exiting"
    Exit 1
fi

kops_download_version=${__config_component_kops_version}
log_it "${__function_name}" "installer" "DEBUG" "1215" "Target version of kops to be installed is: $kops_download_version"

kops_existing_version=""
kops_shell_file=${digi_dir}installer/kops

kops_existing_path=$(which kops)
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" "WARN" "1225" "Error while checking if kops is already installed.  Ignoring and proceeding"
fi

if [[ -f ${kops_existing_path} ]]; then

    file ${kops_existing_path} | grep ASCII
    if [[ $? -gt 0 ]]; then
        log_it "${__function_name}" "installer" "WARN" "1225" "Probably kops shell already available at path: ${kops_existing_path}.  Removing."
        sudo rm ${kops_existing_path}
    else
        file ${kops_existing_path} | grep symbolic
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "WARN" "1225" "Probably softlink to kops binary already available at path: ${kops_existing_path}.  Removing."
            sudo rm ${kops_existing_path}
        else
            log_it "${__function_name}" "installer" "INFO" "1230" "Kops binary already available at path: ${kops_existing_path}.  Renaming."
            sudo mv ${kops_existing_path} ${kops_existing_path}_${RANDOM}_bkp
        fi
    fi

fi

#kops not available.  Download and install
kops_local_path=${__config_component_kops_localPath}
sudo cp --preserve ${kops_shell_file} ${kops_local_path}
_exit_code=$?
if [[ $? -gt 0 ]]; then
  log_it "${__function_name}" "installer" "ERR" "1270" "Error while copying kops shell to ${kops_local_path}"
  exit 1
else        
  if [[ -f "${kops_local_path}" ]]; then
    log_it "${__function_name}" "installer" "DEBUG" "1274" "Moved kops shell to ${kops_local_path}"
    
    chmod +x ${kops_local_path}
    if [[ $? -gt 0 ]]; then
        log_it "${__function_name}" "installer" "ERR" "1255" "Error while changing the file perimissions for the kops shell"
        exit 1
    else
        log_it "${__function_name}" "installer" "DEBUG" "1260" "Changed the access permission of kops shell"
    fi
  else
    log_it "${__function_name}" "installer" "ERR" "1278" "Error while moving kops shell to ${kops_local_path}"
    exit 1
  fi
fi
        
#Check if kops shell is in path
kops_new_path=$(which kops)
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" "ERR" "1280" "Error while checking if kops shell is in path"
    exit 1
fi
if [[ "${kops_new_path}" = "${kops_local_path}" ]]; then
    log_it "${__function_name}" "installer" "DEBUG" "1282" "kops shell is in path"
else 
    log_it "${__function_name}" "installer" "ERR" "1284" "Different kops shell is available in path."
    exit 1
fi
        
kops_inpath_version=$(kops version | cut -d " " -f 2)
if [[ "${kops_inpath_version}" = "${kops_download_version}" ]]; then
    log_it "${__function_name}" "installer" "DEBUG" "1286" "kops binary in path has version: $kops_download_version"
    log_it "${__function_name}" "installer" "INFO" "1288" "Successfully installed kops version: $kops_download_version"
else
    log_it "${__function_name}" "installer" "ERR" "1290" "Incorrect version of kops shell in path.  Expected version: ${kops_download_version} Actual version: ${kops_inpath_version}"
fi
     

