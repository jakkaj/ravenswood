#!/bin/bash

#Jordan Knight (https://github.com/jakkaj) and Regan Murphy (https://github.com/nzregs)
. ./loadconfigs.sh

declare site1cidr="192.168.210.0/24"
declare site1location="eastus"
declare site1serviceCidr="10.0.0.0/16"
declare site1dnsServiceIP="10.0.0.10"
declare site1dockerBridgeCidr="172.17.0.1/16"
declare kubernetesVersion="1.9.6"

# should log in to azure first, but we'll check and initiate
az account show 1> /dev/null

if [ $? != 0 ];
then
	az login
fi

echo "Set Subs: $subscription"
az account set --subscription $subscription

echo "Create RG: $a_rg"

az group create -l $a_location -n $a_rg

depName=cluster_$a_rg

echo "To get creds run: az aks get-credentials --name $depName -g $a_rg"

echo "Starting aks deployment in to $a_location"
(
	set -x
	az group deployment create --name $depName \
                                --resource-group $a_rg \
                                --template-file ../arm/kube-managed.json \
                                --parameters resourceName=$depName \
                                                servicePrincipalClientId=$sp_appid \
                                                servicePrincipalClientSecret=$sp_password \
                                                dnsPrefix=$a_rg \
                                                location=$a_location \
                                                vnetSubnetID=$vnet_a \
                                                networkPlugin=azure \
                                                serviceCidr=$site1serviceCidr \
                                                dnsServiceIP=$site1dnsServiceIP \
                                                dockerBridgeCidr=$site1dockerBridgeCidr  \
                                                kubernetesVersion=$kubernetesVersion
)

(
    set +x
    az aks get-credentials --name $depName -g $a_rg -f $kubeconfig_aks
    echo "Credentials saved to: $kubeconfig_aks"

    cp $kubeconfig_aks $kubeconfig_aks_latest
)

echo "To get creds again run: az aks get-credentials --name $depName -g $a_rg"

echo "To delete again: "
echo "az group delete --name $a_rg"
echo "Done AKS"