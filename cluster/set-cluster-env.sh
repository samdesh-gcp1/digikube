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
    export KOPS_PROJECT=$(get-config-value "cloud.project.name")
    export KOPS_VPC=$(get-config-value "cloud.project.vpc")
    export KOPS_ENV=$(get-config-value "cluster.kops.env")
    export KOPS_CLUSTER_NAME=${KOPS_PROJECT}-${KOPS_ENV}.k8s.local
    export KOPS_STATE_STORE="gs://$(get-config-value 'cloud.bucket.name')"
    export KOPS_REGION=$(get-config-value "cloud.project.region")
    export KOPS_MASTER_ZONES=$(get-config-value "cloud.project.zone")
    export KOPS_WORKER_ZONES=$(get-config-value "cloud.project.zone")
    log_it "${__function_name}" "cluster" "INFO" "2210" "Successfully set the cluster environment"
fi
