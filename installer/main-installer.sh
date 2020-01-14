#!/bin/bash
# Main installer script

base_dir=~/
digi_dir=${base_dir}digikube/

kubectl_installer=${digi_dir}installer/kubectl-installer.sh
${kubectl_installer}

kops_installer=${digi_dir}installer/kops-installer.sh
${kops_installer}

cluster_installer=${digi_dir}cluster/cluster-installer.sh
${cluster_installer}
