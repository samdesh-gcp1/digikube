#!/bin/bash
# Main installer script

BASE_DIR=~/

echo "1"

. ${BASE_DIR}/utility/download-file.sh
. ${BASE_DIR}/utility/parse-yaml.sh

echo "2"

LOG_DIR=${BASE_DIR}digikube-logs/
INSTALLER_LOG=${LOG_DIR}digikube-installer.log
DIGI_DIR=${BASE_DIR}digikube/

KUBECTL_TARGET_VERSION="1.15"
KUBECTL_BINARY_URL="https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_TARGET_VERSION/bin/linux/amd64/kubectl"

echo "3"

KUBECTL_CUR_PATH=$(which kubectl)

echo "4 $KUBECTL_CUR_PATH"

if [[ -z ${KUBECTL_CUR_PATH} ]]; then
    #Kubectl not available.  Download and install
    echo "9"
    
    download_file $KUBECTL_BINARY_URL kubectl_binary
    echo "Downloaded kubectl binary at $kubectl_binary"
   
else
    echo "Kubectl binary already available. Location: ${KUBECTL_CUR_PATH}"

    echo "5"

    eval $(parse_yaml <( kubectl version -o yaml ) "KUBECTL_CUR_")
    f=$KUBECTL_CUR_clientVersion_minor
    t="+"
    s=""
    [ "${f%$t*}" != "$f" ] && n="${f%$t*}$s${f#*$t}"
    KUBECTL_CUR_clientVersion_minor=$n

    echo "6"

    KUBECTL_CUR_VERSION=$KUBECTL_CUR_clientVersion_major.$KUBECTL_CUR_clientVersion_minor
    if [[ "$KUBECTL_CUR_VERSION" = "$KUBECTL_TARGET_VERSION" ]]; then
        echo "Kubectl version is ${KUBECTL_CUR_VERSION}.  Skipping kubectl installation."
        echo "7"
        exit 0
    else
        echo "Kubectl version is ${KUBECTL_CUR_VERSION}.  Required version is ${KUBECTL_TARGET_VERSION}.  Aborting kubectl installation.  Please remove the old version and rerun the installation."
        echo "8"
        exit 1
    fi 
fi
