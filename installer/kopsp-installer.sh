#!/bin/bash
# kops-p installer

__function_name="installer/kopsp-installer.sh"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh

digikube_config=${digi_dir}config/digikube-config.yaml
parse_yaml ${digikube_config} "__config_"

log_it "${__function_name}" "installer" "INFO" "1210" "Started the kops-p installation process"

kops_download_version=${__config_component_kops_version}
log_it "${__function_name}" "installer" "DEBUG" "1215" "Target version of kops-p to be installed is: $kops_download_version"

kops_existing_version=""
kops_download_url=${__config_component_kops_kopsp_url}
log_it "${__function_name}" "installer" "DEBUG" "1220" "Kops-p download site is: $kops_download_url"

kops_existing_path=$(which kopsp)
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" "WARN" "1225" "Error while checking if kops-p is already installed.  Ignoring and proceeding"
fi

if [[ -f ${kops_existing_path} ]]; then

    log_it "${__function_name}" "installer" "INFO" "1230" "Kops-p binary already available at path: ${kops_existing_path}"
    kops_existing_version=$(kopsp version | cut -d " " -f 2)
        
    if [[ "$kops_existing_version" = "$kops_download_version" ]]; then
        log_it "${__function_name}" "installer" "INFO" "1235" "Pre-existing kops-p binary version is same as expected target version: ${kops_download_version}. Using the pre-existing kops-p binary."
    else
        log_it "${__function_name}" "installer" "ERR" "1240" "Pre-existing kops-p binary version is: ${kops_existing_version}.  Target version of kops is: ${kops_download_version}. Aborting kops-p installation.  Remove existing kops-p binary and rerun the installation."
        exit 1
    fi 
    
else

    #kops-p not available.  Download and install
    download_file $kops_download_url kops_binary
    if [[ $? -gt 0 ]]; then
        log_it "${__function_name}" "installer" "ERR" "1245" "Error while downloading kops-p binary"
        exit 1
    fi
    
    if [[ -f ${kops_binary} ]]; then

        log_it "${__function_name}" "installer" "DEBUG" "1250" "Downloaded kops-p binary at: ${kops_binary}"
        
        file ${kops_binary} | grep gzip
        if [[ $? -gt 0 ]]; then
            var1=""
        else
            log_it "${__function_name}" "installer" "INFO" "1255" "kops-p binary is compressed file.  Need to unzip."
            kops_binary_compressed=${kops_binary}
            kops_file_name="kopsp"
            kops_binary=""
            unzip_file ${kops_binary_compressed} ${kops_file_name} kops_binary
            if [[ $? -gt 0 ]]; then
                log_it "${__function_name}" "installer" "ERR" "1255" "Error while unzipping kops-p binary"
                exit 1
            else
                log_it "${__function_name}" "installer" "DEBUG" "1260" "Unzipped kops-p binary"
            fi
        fi
        
        chmod +x ${kops_binary}
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1255" "Error while changing the file perimissions for the downloaded kops-p binary"
            exit 1
        else
            log_it "${__function_name}" "installer" "DEBUG" "1260" "Changed the access permission of kops-p binary"
        fi
        
        kops_download_version=$($kops_binary version | cut -d " " -f 2)
        log_it "${__function_name}" "installer" "DEBUG" "1265" "Downloaded kops-p version is: $kops_download_version"
        
        kops_local_path=${__config_component_kops_kopsp_localPath}
        sudo mv ${kops_binary} ${kops_local_path}
        _exit_code=$?
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1270" "Error while moving kops-p binary to ${kops_local_path}"
            exit 1
        else        
            if [[ -f "${kops_local_path}" ]]; then
                log_it "${__function_name}" "installer" "DEBUG" "1274" "Moved kops-p binary to ${kops_local_path}"
            else
                log_it "${__function_name}" "installer" "ERR" "1278" "Error while moving kops-p binary to ${kops_local_path}"
                exit 1
            fi
        fi
        
        #Check if kops-p binary is in path
        kops_new_path=$(which kopsp)
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1280" "Error while checking if kops-p binary is in path"
            exit 1
        fi
        if [[ "${kops_new_path}" = "${kops_local_path}" ]]; then
            log_it "${__function_name}" "installer" "DEBUG" "1282" "kops-p binary is in path"
        else 
            log_it "${__function_name}" "installer" "ERR" "1284" "Different kops-p binary is available in path."
            exit 1
        fi
        
        kops_inpath_version=$(kopsp version | cut -d " " -f 2)
        if [[ "${kops_inpath_version}" = "${kops_download_version}" ]]; then
            log_it "${__function_name}" "installer" "DEBUG" "1286" "kops-p binary in path has version: $kops_download_version"
            log_it "${__function_name}" "installer" "INFO" "1288" "Successfully installed kops-p version: $kops_download_version"
        else
            log_it "${__function_name}" "installer" "ERR" "1290" "Incorrect version of kops-p binary in path.  Expected version: ${kops_download_version} Actual version: ${kops_inpath_version}"
        fi
    
    else
    
        log_it "${__function_name}" "installer" "ERR" "1292" "Not able to get handle on downloaded kops-p binary"
        exit 1
        
    fi

fi
