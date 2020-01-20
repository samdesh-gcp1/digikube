#!/bin/bash
# Main installer script

base_dir=~/
digi_dir=${base_dir}digikube/
digi_ops_executer=${digi_dir}cluster/digiops

kubectl_installer=${digi_dir}installer/kubectl-installer.sh
${kubectl_installer}
if [[ $? -gt 0 ]]; then
    exit 1
fi

kops_installer=${digi_dir}installer/kops-installer.sh
${kops_installer}
if [[ $? -gt 0 ]]; then
    exit 1
fi

. ${digi_ops_executer}
create-cluster
if [[ $? -gt 0 ]]; then
    exit 1
fi
