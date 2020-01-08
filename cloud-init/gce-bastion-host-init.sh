#!/bin/bash
# Init script

cd ~/
touch digikube-init.log
date >> digikube-init.log

if [[ -d "digikube/" ]]; then
	echo "Dikiguke source directory exists. Refreshing." >> digikube-init.log
	cd digikube/
	git init
else
	echo "Digikube source directory not available. Clonning" >> digikube-init.log
	git clone -o digikube-source https://github.com/samdesh-gcp1/digikube.git
fi
