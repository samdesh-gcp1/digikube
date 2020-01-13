#!/bin/bash
# set cluster environment

__function_name="cluster/set-cluster-env.sh"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh
. ${digi_dir}common/digikube-config.sh

log_it "${__function_name}" "cluster" "DEBUG" "2210" "Setting the cluster environment variables"

validate-digikube-config
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "cluster" "ERR" "2210" "Unreconsiable mismatch between existing environment and configuration.  Exiting."
    exit 1
else
    export KOPS_FEATURE_FLAGS=$(get-config-value "cluster.kops.featureFlags")
    export KOPS_CLOUD=$(get-config-value "cloud.provider")
    export KOPS_PROJECT=$(get-config-value "cloud.provider.project")
    export KOPS_VPC=digikube-vpc
export KOPS_ENV=dev1
export KOPS_CLUSTER_NAME=${KOPS_PROJECT}-${KOPS_ENV}.k8s.local
export KOPS_STATE_STORE=gs://${KOPS_PROJECT}-bucket/
export KOPS_REGION=us-central1
export KOPS_MASTER_ZONES=us-central1-c
export KOPS_WORKER_ZONES=us-central1-c

