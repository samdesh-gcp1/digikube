#!/bin/bash
# Main installer script

BASE_DIR=~/

LOG_DIR=${BASE_DIR}digikube-logs/
INSTALLER_LOG=${LOG_DIR}digikube-installer.log

touch $INSTALLER_LOG
date >> $INSTALLER_LOG

DIGI_DIR=${BASE_DIR}digikube/
KUBECTL_INSTALLER=${DIGI_DIR}installer/kubectl.sh

${KUBECTL_INSTALLER}
