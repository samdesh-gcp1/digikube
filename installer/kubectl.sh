#!/bin/bash
# kubectl installer

__function_name="installer/kubectl.sh"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh

eval $(parse_yaml ${digikube_config} )

log_it "${__function_name}" "installer" 1 "0000" "Started the kubectl installation process"

kubectl_download_version="1.15"
log_it "${__function_name}" "installer" 0 "0000" "Target version of kubectl to be installed is: $kubectl_download_version"

kubectl_existing_version=""
kubectl_download_url="https://storage.googleapis.com/kubernetes-release/release/v$kubectl_download_version.0/bin/linux/amd64/kubectl"
log_it "${__function_name}" "installer" 0 "0000" "Kubectl download site is: $kubectl_download_url"

kubectl_existing_path=$(which kubectl)
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" 2 "0000" "Error while checking if kubectl is already installed"
fi

if [[ -z ${kubectl_existing_path} ]]; then

    #Kubectl not available.  Download and install
    download_file $kubectl_download_url kubectl_binary
    if [[ $? -gt 0 ]]; then
        log_it "${__function_name}" "installer" 3 "0000" "Error while downloading kubectl binary"
        exit 1
    fi
    
    if [[ -z ${kubectl_binary} ]]; then
        log_it "${__function_name}" "installer" 3 "0000" "Not able to get handle on downloaded kubectl binary"
        exit 1
    else
        log_it "${__function_name}" "installer" 0 "0000" "Downloaded kubectl binary at: ${kubectl_binary}"
        
        chmod +x ${kubectl_binary}
        if [[ $? -gt 0 ]]; then
            log_it "${__function_name}" "installer" 3 "0000" "Error while changing the file perimissions for the downloaded kubectl binary"
            exit 1
        else
            log_it "${__function_name}" "installer" 0 "0000" "Changed the access permission of kubectl binary"
        fi
        
        eval $(parse_yaml <( $kubectl_binary version -o yaml ) "kubectl_download_")
        #kubectl_download_clientVersion_minor="$(replace_substring '$kubectl_download_clientVersion_minor' '+' '')"
        kubectl_download_version=$kubectl_download_clientVersion_major.$kubectl_download_clientVersion_minor
        
        log_it "${__function_name}" "installer" 0 "0000" "Downloaded kubectl version is: $kubectl_download_version"
        
    fi

else

    log_it "${__function_name}" "installer" 1 "0000" "Kubectl binary already available at path: ${kubectl_existing_path}"
    eval $(parse_yaml <( kubectl version -o yaml ) "kubectl_existing_")
    kubectl_existing_clientVersion_minor="$(replace_substring $kubectl_existing_clientVersion_minor '+' ' ')"
    
    #f=$KUBECTL_CUR_clientVersion_minor
    #t="+"
    #s=""
    #[ "${f%$t*}" != "$f" ] && n="${f%$t*}$s${f#*$t}"
    #KUBECTL_CUR_clientVersion_minor=$n

    kubectl_existing_version=$kubectl_existing_clientVersion_major.$kubectl_existing_clientVersion_minor
    
    if [[ "$kubectl_existing_version" = "$kubectl_download_version" ]]; then
        log_it "${__function_name}" "installer" 1 "0000" "Pre-existing kubectl binary version is same as expected target version: ${kubectl_download_version}. Using the pre-existing kubectl binary."
    else
        log_it "${__function_name}" "installer" 3 "0000" "Pre-existing kubectl binary version is: ${kubectl_existing_version}.  Target version of kubectl is: ${kubectl_download_version}. Aborting kubectl installation.  Remove existing kubectl binary and rerun the installation."
        exit 1
    fi 
fi
