#!/bin/bash
# Init script
INIT_SCRIPT_SOURCE="$(wget -q -O - https://raw.githubusercontent.com/samdesh-gcp1/digikube/master/cloud-init/gce-bastion-host-init.sh | bash)"
su - samdesh_gcp1 --preserve-environment -c "$INIT_SCRIPT_SOURCE"
