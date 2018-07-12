#!/bin/bash

#Jordan Knight (https://github.com/jakkaj) and Regan Murphy (https://github.com/nzregs)
. ./loadconfigs.sh

# should log in to azure first, but we'll check and initiate
az account show 1> /dev/null

if [ $? != 0 ];
then
	az login
fi

echo "Set Subs: $subscription"
az account set --subscription $subscription

echo "Create RG: $b_rg"

az group create -l $b_location -n $b_rg

cp ../acsengine/ClusterA/buildacs.template.json ../acsengine/ClusterA/buildacs.json 

sed -i "s|!vnet|$vnet_b|g" "../acsengine/ClusterA/buildacs.json" 
sed -i "s|!dns|$b_rg|g" "../acsengine/ClusterA/buildacs.json" 

acs-engine generate --output-directory ../builds/$ver/$b_rg ../acsengine/ClusterA/buildacs.json

depName=cluster_$b_rg

cp $PWD/../builds/$ver/$b_rg/kubeconfig/kubeconfig.$b_location.json ../builds/$ver/$b_rg/kubeconfig.json
cp $PWD/../builds/$ver/$b_rg/kubeconfig/kubeconfig.$b_location.json $kubeconfig_acs
cp $kubeconfig_acs $kubeconfig_acs_latest
echo "Credentials saved to: $kubeconfig_acs and to $kubeconfig_acs_latest"



echo "export KUBECONFIG=$PWD/../builds/$ver/$b_rg/kubeconfig.json" > ../builds/$ver/$b_rg/kubeconfig.sh
echo "$PWD/../builds/$ver/$b_rg/kubeconfig.json" > ../builds/$ver/$b_rg/kubeconfig.txt
chmod +x ../builds/$ver/$b_rg/kubeconfig.sh
export KUBECONFIG=$PWD/../builds/$ver/$b_rg/kubeconfig.json

echo "The kubeconfig file will be: ../builds/$ver/$b_rg/kubeconfig.json"
echo "use: export KUBECONFIG=$PWD/../builds/$ver/$b_rg/kubeconfig.json"
echo "or: . $PWD/../builds/$ver/$b_rg/kubeconfig.sh"
echo ""
echo "Deploying deployment $depName in resource group $b_rg"

cp config.json ../builds/$ver/$b_rg/config.json

az group deployment create \
    --name "$depName" \
    --resource-group "$b_rg" \
    --template-file "../builds/$ver/$b_rg/azuredeploy.json" \
    --parameters "../builds/$ver/$b_rg/azuredeploy.parameters.json"


echo ""
echo "To delete again: "
echo "az group delete --name $b_rg"

echo ""
echo "The kubeconfig file will be: ../builds/$ver/$b_rg/kubeconfig.json"
echo "use: export KUBECONFIG=$PWD/../builds/$ver/$b_rg/kubeconfig.json"
echo "or: . $PWD/../builds/$ver/$b_rg/kubeconfig.sh"
echo "then run the second script (2.config_custer.sh)"
echo "Done acsengine"



