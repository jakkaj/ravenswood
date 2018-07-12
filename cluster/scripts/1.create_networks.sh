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

echo "Create RG: $b_rg and $a_rg"

az group create -l $b_location -n $b_rg &
az group create -l $a_location -n $a_rg &

wait

echo "Create storage"
set -x
declare storage=s-${a_rg:0:18}
storage="${storage,,}"
storage="${storage//-}"

    
az storage account create -n $storage -g $a_rg -l $a_location --sku Standard_LRS &


echo "Create vnet $a_vnet"
az network vnet create --name $a_vnet \
    --location $a_location --resource-group $a_rg \
    --address-prefix 192.168.210.0/24\
    --subnet-name default\
    --subnet-prefix 192.168.210.0/24 &

echo "Create vnet $b_vnet"
az network vnet create --name $b_vnet \
    --location $b_location --resource-group $b_rg \
    --address-prefix 192.168.201.0/24\
    --subnet-name default\
    --subnet-prefix 192.168.201.0/24 &

wait 

declare vnet_a_json=$(az network vnet show --name $a_vnet\
    --resource-group $a_rg\
    | jq -r .subnets[0].id)

declare vnet_a_id=$(az network vnet show --name $a_vnet\
    --resource-group $a_rg\
    | jq -r .id)

declare vnet_b_json=$(az network vnet show --name $b_vnet\
    --resource-group $b_rg\
    | jq -r .subnets[0].id) 

declare vnet_b_id=$(az network vnet show --name $b_vnet\
    --resource-group $b_rg\
    | jq -r .id)

export vnet_a=$vnet_a_json
export vnet_b=$vnet_b_json

declare a_vnetpeername=$a_vnet-peer
declare b_vnetpeername=$b_vnet-peer

echo "Peering: $a_vnet to $b_vnet"

az network vnet peering create --resource-group $a_rg \
                                --name $a_vnetpeername \
                                --vnet-name $a_vnet \
                                --remote-vnet-id $vnet_b_id \
                                --allow-vnet-access &

echo "Peering: $b_vnet to $a_vnet"

az network vnet peering create --resource-group $b_rg \
                                --name $b_vnetpeername \
                                --vnet-name $b_vnet \
                                --remote-vnet-id $vnet_a_id \
                                --allow-vnet-access &

wait