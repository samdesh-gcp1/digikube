#!/bin/bash
# cluster installer

__function_name="cluster/install.sh"

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

kops create cluster                  \
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

__kops_exit_status=$?
if [[ ${__kops_exit_status} -gt 0 ]]; then
    log_it "${__function_name}" "installer" "ERR" "2110" "Error while creating kops cluster"
    exit 1
else
    
    log_it "${__function_name}" "installer" "INFO" "2110" "Cluster created successfully.  Waiting for initialization"
    __kops_exit_status=1
    __loop_count=0
    __max_loop_count=30
    __loop_sleep_duration=10 

    while [ ${__kops_exit_status} -gt 0 ]
    do
        kops validate cluster --state=${KOPS_STATE_STORE}
        __kops_exit_status=$?
        __loop_count=${__loop_count} + 1
        if [[ ${__loop_count} -gt ${__max_loop_count} ]]; then
             break
        fi
        sleep ${__loop_sleep_duration}
    done
    
    if [[ ${__loop_count} -gt ${__max_loop_count} ]]; then
        #This is timeout condition
        log_it "${__function_name}" "installer" "ERR" "2110" "Timeout while validating cluster setup"
        exit 1
    else
        log_it "${__function_name}" "installer" "INFO" "2110" "Cluster initialized successfully"
        log_it "${__function_name}" "installer" "DEBUG" "2110" "Cluster details : $(kops validate cluster --state=${KOPS_STATE_STORE})"
    fi
fi
