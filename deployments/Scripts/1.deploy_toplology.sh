#!/bin/bash

#needs yamlwriter node app installed

. ./loadconfigs.sh

. ./configkube.sh $1

declare setter="--set Version=$ver --set Build=$build --set topology_name=enrich-demo-$ver-$build"

export KUBECONFIG=$kubeconfig_aks
echo "Config: $kubeconfig_aks"

echo "Deploy Toplogy"

helm template $setter -f ../Helm/topology/values.yaml ../Helm/topology | kubectl $kcommand -f -

export KUBECONFIG=$kubeconfig_acs
echo "Config: $kubeconfig_acs"

helm template $setter -f ../Helm/topology/values.yaml ../Helm/topology | kubectl $kcommand -f -

#helm install $setter --wait -f ../Helm/toplogy/values.yaml ../Helm/toplogy

#exit 0

# export KUBECONFIG=$kubeconfig_acs
# echo "Config: $kubeconfig_acs"

# #helm init

# echo "Deploy Toplogy"



# echo "Setting KUBECONFIG to $kubeconfig_aks"

# export KUBECONFIG=$kubeconfig_aks

# helm install $setter --wait --name toplogy-$ver-$build -f ../Helm/topology/values.yaml ../Helm/topology