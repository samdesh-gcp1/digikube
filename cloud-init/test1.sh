#! /bin/bash
echo "This is test"
echo "-- metadata='$(wget -q -O - https://raw.githubusercontent.com/samdesh-gcp1/private/master/cloud-init/gce-bastion-host-init.sh | bash )'"
