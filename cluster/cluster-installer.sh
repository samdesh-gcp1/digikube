#!/bin/bash
# cluster installer

__function_name="cluster/install.sh"

rcho "AAAAAAAAAA"

base_dir=~/
digi_dir=${base_dir}digikube/

. ${digi_dir}utility/general.sh
. ${digi_dir}utility/log.sh

log_it "${__function_name}" "installer" "INFO" "2110" "Started the cluster installation process"

. ${digi_dir}cluster/set-cluster-env.sh
if [[ $? -gt 0 ]]; then
    log_it "${__function_name}" "installer" "ERR" "2110" "Error while setting cluster environment"
    exit 1
fi

log_it "${__function_name}" "installer" "DEBUG" "2110" "KOPS_FEATURE_FLAGS = ${KOPS_FEATURE_FLAGS}"
log_it "${__function_name}" "installer" "DEBUG" "2110" "KOPS_CLOUD = ${KOPS_CLOUD}"
#export KOPS_PROJECT=`gcloud config get-value project`
#export KOPS_VPC=digikube-vpc
#export KOPS_ENV=dev1
#export KOPS_CLUSTER_NAME=${KOPS_PROJECT}-${KOPS_ENV}.k8s.local
#export KOPS_STATE_STORE=gs://${KOPS_PROJECT}-bucket/
#export KOPS_REGION=us-central1
#export KOPS_MASTER_ZONES=us-central1-c
#export KOPS_WORKER_ZONES=us-central1-c
 
echo "Kubernetes cluster will be created with the following details."

echo "KOPS FEATURE FLAGS        : " ${KOPS_FEATURE_FLAGS}
echo "Cloud Engine              : " ${KOPS_CLOUD}
echo "Cloud Project             : " ${KOPS_PROJECT}
echo "Cloud VPC                 : " ${KOPS_VPC}
echo "Environemnt               : " ${KOPS_ENV}
echo "Cluster Name              : " ${KOPS_CLUSTER_NAME}
echo "KOPS State Store          : " ${KOPS_STATE_STORE}
echo "Cloud Zones for Masters   : " ${KOPS_MASTER_ZONES}
echo "Cloud Zones for Workers   : " ${KOPS_WORKER_ZONES}

kops_preemptible create cluster                  \
    --name=${KOPS_CLUSTER_NAME}      \
    --cloud=${KOPS_CLOUD}            \
    --project=${KOPS_PROJECT}        \
    --master-zones=${KOPS_MASTER_ZONES} \
    --zones=${KOPS_WORKER_ZONES}     \
    --cloud-labels=${KOPS_ENV_TYPE}  \
    --master-count=1                 \
    --master-size=g1-small           \
    --master-volume-size=10          \
    --node-count=2                   \
    --node-size=g1-small             \
    --node-volume-size=10            \
    --associate-public-ip=false      \
    --api-loadbalancer-type=public   \
    --authorization=RBAC             \
    --etcd-storage-type=pd-standard  \
    --state=${KOPS_STATE_STORE}      \
    --yes
