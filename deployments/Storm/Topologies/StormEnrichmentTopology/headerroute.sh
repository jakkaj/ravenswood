#!/bin/bash
export targetfile=./builds/$build/shift-$V1Split-$V2Split-split.yaml
echo $targetfile
export setter="--set Version=$ver --set Build=$build --set Svc=$svc --set TargetVersion=$TargetVersion --set OtherVersion=$OtherVersion --set HeaderName=$HeaderName --set HeaderRegex=$HeaderRegex"

(
    set +x
    helm template $setter -f ../Istio/headerroute/values.yaml ../Istio/headerroute > $targetfile
)

export KUBECONFIG=$kubeconfig_aks
echo "Config: $kubeconfig_aks"

kubectl apply -f $targetfile

export KUBECONFIG=$kubeconfig_acs
echo "Config: $kubeconfig_acs"

kubectl apply -f $targetfile