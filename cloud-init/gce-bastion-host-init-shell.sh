#!/bin/bash
# Init script

if [ $# -gt 0 ]; then
  DIGIKUBE_CLOUD_ADMIN=$1
else
  DIGIKUBE_CLOUD_ADMIN=$(whoami)
fi

INIT_SCRIPT_SOURCE="$(wget -q -O - https://raw.githubusercontent.com/samdesh-gcp1/digikube/master/cloud-init/gce-bastion-host-init.sh | bash)"

su - $(DIGIKUBE_CLOUD_ADMIN) --preserve-environment -c "$INIT_SCRIPT_SOURCE"
