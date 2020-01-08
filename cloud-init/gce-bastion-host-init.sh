#!/bin/bash
# Init script

cd ~/
mkdir ~/digikube-logs
touch ~/digikube-logs/digikube-init.log
LOG_FILE=~/digikube-logs/digikube-installer.log

LOG_DIR=~/digikube-logs/
if [[ -d $LOG_DIR ]]; then

else
	mkdir $LOG_DIR
fi
INIT_LOG=~/$LOG_DIR/digikube-init.log
INSTALLER_LOG=~/$LOG_DIR/digikube-installer.log
date >> ~/digikube-init.log

GIT_REPO_URL="https://github.com/samdesh-gcp1/digikube.git"

BASE_DIR=~/
DIGI_DIR=~/digikube/
if [[ -d $DIGI_DIR ]]; then
	echo "Dikiguke source directory exists. Refreshing." >> $INIT_LOG
	cd $DIGI_DIR
	git init
	if [ $? -gt 0 ]; then
		echo "Error while refreshing dikiguke source directory. Aborting." >> $INIT_LOG
		exit 1
	else
		echo "Refreshed dikiguke source directory." >> $INIT_LOG
		cd $DIGI_DIR
		git pull
		if [ $? -gt 0 ]; then
			echo "Error while pulling dikiguke source directory. Aborting." >> $INIT_LOG
			exit 1
		else
			echo "Pulled dikiguke source directory." >> $INIT_LOG
		fi	
	fi	
else
	echo "Digikube source directory not available. Clonning" >> $INIT_LOG
	cd $BASE_DIR
	git clone -o digikube-source $GIT_REPO_URL
	if [ $? -gt 0 ]; then
		echo "Error while clonning dikiguke source directory. Aborting." >> $INIT_LOG
		exit 1
	else
		echo "Clonned dikiguke source directory." >> $INIT_LOG
	fi	
fi

if [[ -e "$DIGI_DIR"installer/main.sh ]]; then
	echo "Starting digikube main installation." >> $INIT_LOG
	"$DIGI_DIR"installer/main.sh
	if [[ $? -gt 0 ]]; then
		echo "Error during Digikube installation.  Please check installation log for details." >> $INIT_LOG
		exit 1
	else
		echo "Completed Digikube installation.  Please check installation log for details." >> $INIT_LOG
	fi
else
	echo "Digikube main installer not found. Aborting." >> $INIT_LOG
	exit 1
fi


