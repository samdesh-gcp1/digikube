#!/bin/bash
# Init script

#Do not change the bellow line -- will be replaced at runtime
#<placeholder for digikube admin user name>

if [ $# -gt 0 ]; then
  DIGIKUBE_CLOUD_ADMIN=$1
else
  if [ -z $DIGIKUBE_CLOUD_ADMIN ]; then
    DIGIKUBE_CLOUD_ADMIN=$(whoami)
  else
    DIGIKUBE_CLOUD_ADMIN=$DIGIKUBE_CLOUD_ADMIN
  fi
fi

#INIT_SCRIPT_SOURCE="$(wget -q -O - https://raw.githubusercontent.com/samdesh-gcp1/digikube/master/cloud-init/gce-bastion-host-init.sh | bash)"
#su - $(DIGIKUBE_CLOUD_ADMIN) --preserve-environment -c "$INIT_SCRIPT_SOURCE"

INIT_SCRIPT_SOURCE="wget -q --no-cache -O /tmp/gce-bastion-host-init.sh - https://raw.githubusercontent.com/samdesh-gcp1/digikube/master/cloud-init/gce-bastion-host-init.sh"

su - $DIGIKUBE_CLOUD_ADMIN --preserve-environment -c "$INIT_SCRIPT_SOURCE"

su - $DIGIKUBE_CLOUD_ADMIN --preserve-environment -c "chmod +x /tmp/gce-bastion-host-init.sh"

su - $DIGIKUBE_CLOUD_ADMIN --preserve-environment -c "/tmp/gce-bastion-host-init.sh"
