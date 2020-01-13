#!/bin/bash
# set cluster environment

__function_name="cluster/set-cluster-env.sh"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh

log_it "${__function_name}" "cluster" "DEBUG" "2210" "Setting the cluster environment variables"

digikube_config=${digi_dir}config/digikube-config.yaml
eval $(parse_yaml ${digikube_config} "__config_" )

export KOPS_FEATURE_FLAGS=${__config_cluster_kops_featureFlags}
export KOPS_CLOUD=${__config_cloud_provider}
if [[ 
export KOPS_PROJECT=`gcloud config get-value project`
export KOPS_VPC=digikube-vpc
export KOPS_ENV=dev1
export KOPS_CLUSTER_NAME=${KOPS_PROJECT}-${KOPS_ENV}.k8s.local
export KOPS_STATE_STORE=gs://${KOPS_PROJECT}-bucket/
export KOPS_REGION=us-central1
export KOPS_MASTER_ZONES=us-central1-c
export KOPS_WORKER_ZONES=us-central1-c

