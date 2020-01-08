#!/bin/bash
# Init script

BASE_DIR=~/

LOG_DIR=${BASE_DIR}digikube-logs/
if [[ -d ${LOG_DIR} ]]; then
	echo "Dikiguke log directory exists."
else
	echo "Dikiguke log directory not available.  Creating new."
	mkdir ${LOG_DIR}
fi
INIT_LOG=${LOG_DIR}digikube-init.log
INSTALLER_LOG=${LOG_DIR}digikube-installer.log

touch $INIT_LOG
date >> $INIT_LOG

GIT_REPO_URL="https://github.com/samdesh-gcp1/digikube.git"
DIGI_DIR=${BASE_DIR}digikube/
MAIN_INSTALLER=${DIGI_DIR}installer/main.sh

echo "testtest"
echo ${MAIN_INSTALLER}

if [[ -d ${DIGI_DIR} ]]; then
	echo "Dikiguke source directory exists. Refreshing." >> ${INIT_LOG}
	cd ${DIGI_DIR}
	git init
	if [ $? -gt 0 ]; then
		echo "Error while refreshing dikiguke source directory. Aborting." >> ${INIT_LOG}
		exit 1
	else
		echo "Refreshed dikiguke source directory." >> ${INIT_LOG}
		cd ${DIGI_DIR}
		git pull
		if [ $? -gt 0 ]; then
			echo "Error while pulling dikiguke source directory. Aborting." >> ${INIT_LOG}
			exit 1
		else
			echo "Pulled dikiguke source directory." >> ${INIT_LOG}
		fi	
	fi	
else
	echo "Digikube source directory not available. Clonning" >> ${INIT_LOG}
	cd ${BASE_DIR}
	git clone -o digikube-source ${GIT_REPO_URL}
	if [ $? -gt 0 ]; then
		echo "Error while clonning dikiguke source directory. Aborting." >> ${INIT_LOG}
		exit 1
	else
		echo "Clonned dikiguke source directory." >> ${INIT_LOG}
	fi	
fi

if [[ -e ${MAIN_INSTALLER} ]]; then
	echo "Starting digikube main installation." >> ${INIT_LOG}
	${MAIN_INSTALLER}
	if [[ $? -gt 0 ]]; then
		echo "Error during Digikube installation.  Please check installation log for details." >> ${INIT_LOG}
		exit 1
	else
		echo "Completed Digikube installation.  Please check installation log for details." >> ${INIT_LOG}
	fi
else
	echo "Digikube main installer not found. Aborting." >> ${INIT_LOG}
	exit 1
fi


