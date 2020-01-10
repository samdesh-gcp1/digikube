. ./set-kops-env.sh
  
echo "Kubernetes cluster will be created with the following details.  Do you wish to continue? (y / N)"

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
