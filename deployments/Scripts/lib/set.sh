#!/bin/bash
export targetfile=./builds/$build/$svc-$targetversion.yaml
echo $targetfile
export setter="--set Version=$ver --set Build=$build --set TargetVersion=$targetversion --set Svc=$svc"

(
    set +x
    helm template $setter -f ../Istio/svc/values.yaml ../Istio/svc > $targetfile
)

export KUBECONFIG=$kubeconfig_aks
echo "Config: $kubeconfig_aks"

kubectl apply -f $targetfile

export KUBECONFIG=$kubeconfig_acs
echo "Config: $kubeconfig_aks"

kubectl apply -f $targetfile