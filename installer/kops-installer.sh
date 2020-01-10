#!/bin/bash
# kops installer

__function_name="installer/kops_installer.sh"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh

digikube_config=${digi_dir}config/digikube-config.yaml
eval $(parse_yaml ${digikube_config} "__config_" )

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
    eval $(parse_yaml <( kops version -o yaml ) "kops_existing_")
    #kops_existing_clientVersion_minor="$(replace_substring $kops_existing_clientVersion_minor '+' ' ')"
    
    #f=$kops_CUR_clientVersion_minor
    #t="+"
    #s=""
    #[ "${f%$t*}" != "$f" ] && n="${f%$t*}$s${f#*$t}"
    #kops_CUR_clientVersion_minor=$n

    kops_existing_version=$kops_existing_clientVersion_major.$kops_existing_clientVersion_minor
    echo $kops_existing_version
    
    if [[ "$kops_existing_version" = "$kops_download_version" ]]; then
        log_it "${__function_name}" "installer" "INFO" "1135" "Pre-existing kops binary version is same as expected target version: ${kops_download_version}. Using the pre-existing kops binary."
    else
        log_it "${__function_name}" "installer" "ERR" "1140" "Pre-existing kops binary version is: ${kops_existing_version}.  Target version of kops is: ${kops_download_version}. Aborting kops installation.  Remove existing kops binary and rerun the installation."
        exit 1
    fi 
    
else

    #kops not available.  Download and install
    download_file $kops_download_url kops_binary
    if [[ $? -gt 0 ]]; then
        log_it "${__function_name}" "installer" "ERR" "1145" "Error while downloading kops binary"
        exit 1
    fi
    
    if [[ -f ${kops_binary} ]]; then

        log_it "${__function_name}" "installer" "DEBUG" "1150" "Downloaded kops binary at: ${kops_binary}"
        
        chmod +x ${kops_binary}
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1155" "Error while changing the file perimissions for the downloaded kops binary"
            exit 1
        else
            log_it "${__function_name}" "installer" "DEBUG" "1160" "Changed the access permission of kops binary"
        fi
        
        eval $(parse_yaml <( $kops_binary version -o yaml ) "kops_download_")
        #kops_download_clientVersion_minor="$(replace_substring '$kops_download_clientVersion_minor' '+' '')"
        #There might be difference in kops version command between different installations/versions.  Need to explore.
        kops_download_version=$kops_download_clientVersion_major.$kops_download_clientVersion_minor
        
        log_it "${__function_name}" "installer" "DEBUG" "1165" "Downloaded kops version is: $kops_download_version"
        
        kops_local_path=${__config_component_kops_localPath}
        sudo mv ${kops_binary} ${kops_local_path}
        _exit_code=$?
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1170" "Error while moving kops binary to ${kops_local_path}"
            exit 1
        else        
            if [[ -f "${kops_local_path}" ]]; then
                log_it "${__function_name}" "installer" "DEBUG" "1174" "Moved kops binary to ${kops_local_path}"
            else
                log_it "${__function_name}" "installer" "ERR" "1178" "Error while moving kops binary to ${kops_local_path}"
                exit 1
            fi
        fi
        
        #Check if kops binary is in path
        kops_new_path=$(which kops)
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" "ERR" "1180" "Error while checking if kops binary is in path"
            exit 1
        fi
        if [[ "${kops_new_path}" = "${kops_local_path}" ]]; then
            temp1=""
            log_it "${__function_name}" "installer" "DEBUG" "1182" "kops binary is in path"
        else 
            log_it "${__function_name}" "installer" "ERR" "1184" "Different kops binary is available in path."
            exit 1
        fi
        
        eval $(parse_yaml <( kops version -o yaml ) "kops_inpath_")
        kops_inpath_version=$kops_inpath_clientVersion_major.$kops_inpath_clientVersion_minor
        if [[ "${kops_inpath_version}" = "${kops_download_version}" ]]; then
            log_it "${__function_name}" "installer" "DEBUG" "1186" "kops binary in path has version: $kops_download_version"
            log_it "${__function_name}" "installer" "INFO" "1188" "Successfully installed kops version: $kops_download_version"
        else
            log_it "${__function_name}" "installer" "ERR" "1190" "Incorrect version of kops binary in path.  Expected version: ${kops_download_version} Actual version: ${kops_inpath_version}"
        fi
    
    else
    
        log_it "${__function_name}" "installer" "ERR" "1192" "Not able to get handle on downloaded kops binary"
        exit 1
        
    fi

fi
