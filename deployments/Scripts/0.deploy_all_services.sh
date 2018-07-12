#!/bin/bash

#needs yamlwriter node app installed

. ./loadconfigs.sh

echo "$kubeconfig_aks"

. ./configkube.sh $1

export KUBECONFIG=$kubeconfig_aks
echo "Config: $kubeconfig_aks"
#helm init

export storage_account=$(kubectl get configmap ravenswoodconfig -o json | jq -r .data.storage)

export setter="--set Version=$ver --set Build=$build --set StorageAccount=$storage_account \
    --set eventhub_read_policy_key=$eventhub_read_policy_key \
    --set eventhub_read_policy_name=$eventhub_read_policy_name \
    --set eventhub_name=$eventhub_name \
    --set eventhub_namespace=$eventhub_namespace \
    --set cosmos_service_endpoint=$cosmos_service_endpoint \
    --set cosmos_key=$cosmos_key \
    --set cosmos_collection_name=$cosmos_collection_name \
    --set cosmos_database_name=$cosmos_database_name"

echo "Helm configs: $setter"
echo $eventhub_namespace


./lib/services.sh &

export KUBECONFIG=$kubeconfig_acs
echo "Config: $kubeconfig_acs"

./lib/services.sh &

echo "Waiting for scripts..."
wait
echo "Both clusters are ready."
