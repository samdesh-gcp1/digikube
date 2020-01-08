#!/bin/bash
# Main installer script

BASE_DIR=~/
LOG_DIR=${BASE_DIR}digikube-logs/
INSTALLER_LOG=${LOG_DIR}digikube-installer.log
DIGI_DIR=${BASE_DIR}digikube/

KUBECTL_VERSION="1.15"

if [[ -z $(which kubectl) ]]; then
        
else
    #Kubectl not available.
    
