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

kops_download_version=${__config_component_kops_version}
log_it "${__function_name}" "installer" "DEBUG" "1215" "Target version of kops to be installed is: $kops_download_version"

kops_existing_version=""
kops_download_url=${__config_component_kops_url}
log_it "${__function_name}" "installer" "DEBUG" "1220" "Kops download site is: $kops_download_url"

kops_existing_path=$(which kops)
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" "WARN" "1225" "Error while checking if kops is already installed.  Ignoring and proceeding"
fi

if [[ -f ${kops_existing_path} ]]; then

    log_it "${__function_name}" "installer" "INFO" "1230" "Kops binary already available at path: ${kops_existing_path}"
    kops_existing_version=$(kops version | cut -d " " -f 2)
        
    if [[ "$kops_existing_version" = "$kops_download_version" ]]; then
        log_it "${__function_name}" "installer" "INFO" "1235" "Pre-existing kops binary version is same as expected target version: ${kops_download_version}. Using the pre-existing kops binary."
    else
        log_it "${__function_name}" "installer" "ERR" "1240" "Pre-existing kops binary version is: ${kops_existing_version}.  Target version of kops is: ${kops_download_version}. Aborting kops installation.  Remove existing kops binary and rerun the installation."
        exit 1
    fi 
    
else

    #kops not available.  Download and install
    download_file $kops_download_url kops_binary
    if [[ $? -gt 0 ]]; then
        log_it "${__function_name}" "installer" "ERR" "1245" "Error while downloading kops binary"
        exit 1
    fi
    
    if [[ -f ${kops_binary} ]]; then

        log_it "${__function_name}" "installer" "DEBUG" "1250" "Downloaded kops binary at: ${kops_binary}"
        
        chmod +x ${kops_binary}
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1255" "Error while changing the file perimissions for the downloaded kops binary"
            exit 1
        else
            log_it "${__function_name}" "installer" "DEBUG" "1260" "Changed the access permission of kops binary"
        fi
        
        kops_download_version=$($kops_binary version | cut -d " " -f 2)
        log_it "${__function_name}" "installer" "DEBUG" "1265" "Downloaded kops version is: $kops_download_version"
        
        kops_local_path=${__config_component_kops_localPath}
        sudo mv ${kops_binary} ${kops_local_path}
        _exit_code=$?
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1270" "Error while moving kops binary to ${kops_local_path}"
            exit 1
        else        
            if [[ -f "${kops_local_path}" ]]; then
                log_it "${__function_name}" "installer" "DEBUG" "1274" "Moved kops binary to ${kops_local_path}"
            else
                log_it "${__function_name}" "installer" "ERR" "1278" "Error while moving kops binary to ${kops_local_path}"
                exit 1
            fi
        fi
        
        #Check if kops binary is in path
        kops_new_path=$(which kops)
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1280" "Error while checking if kops binary is in path"
            exit 1
        fi
        if [[ "${kops_new_path}" = "${kops_local_path}" ]]; then
            log_it "${__function_name}" "installer" "DEBUG" "1282" "kops binary is in path"
        else 
            log_it "${__function_name}" "installer" "ERR" "1284" "Different kops binary is available in path."
            exit 1
        fi
        
        kops_inpath_version=$(kops version | cut -d " " -f 2)
        if [[ "${kops_inpath_version}" = "${kops_download_version}" ]]; then
            log_it "${__function_name}" "installer" "DEBUG" "1286" "kops binary in path has version: $kops_download_version"
            log_it "${__function_name}" "installer" "INFO" "1288" "Successfully installed kops version: $kops_download_version"
        else
            log_it "${__function_name}" "installer" "ERR" "1290" "Incorrect version of kops binary in path.  Expected version: ${kops_download_version} Actual version: ${kops_inpath_version}"
        fi
    
    else
    
        log_it "${__function_name}" "installer" "ERR" "1292" "Not able to get handle on downloaded kops binary"
        exit 1
        
    fi

fi
