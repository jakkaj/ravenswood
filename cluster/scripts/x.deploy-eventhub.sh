#!/bin/bash -v

# unique deployment name
# if you make this too big, deployment will fail. should implement checks :-)
declare uniqueName="nzregsfriday2"
declare resourceGroup="${uniqueName}_rg"
declare eventHubName="${uniqueName}_eh"
declare eventHubNameSpace="${uniqueName}"
declare skuName="Standard"
declare maximumThroughputUnits=5
declare enableAutoInflate=true
declare messageRetentionDays=4
declare partitionCount=10


declare location="eastus"

#create resource groups
az group create -n $resourceGroup -l $location

#create the namespace
# https://docs.microsoft.com/en-us/cli/azure/eventhubs/namespace?view=azure-cli-latest#az-eventhubs-namespace-create 
az eventhubs namespace create --name $eventHubNameSpace --resource-group $resourceGroup  \
    --sku $skuName \
    --enable-auto-inflate $enableAutoInflate --maximum-throughput-units $maximumThroughputUnits \

# create the event hub
# NB this fails if partition count is set <10 bug?
# https://docs.microsoft.com/en-us/cli/azure/eventhubs/eventhub?view=azure-cli-latest
az eventhubs eventhub create --name $eventHubName \
    --resource-group $resourceGroup --namespace-name $eventHubNameSpace  \
    --message-retention $messageRetentionDays --partition-count $partitionCount

# create and fetch authorization keys
# https://docs.microsoft.com/en-us/cli/azure/eventhubs/namespace/authorization-rule/keys?view=azure-cli-latest#az-eventhubs-namespace-authorization-rule-keys-list
az eventhubs namespace authorization-rule create --resource-group $resourceGroup --namespace-name $eventHubNameSpace --name "${uniqueName}sender" --rights Send
az eventhubs namespace authorization-rule keys list --resource-group $resourceGroup --namespace-name $eventHubNameSpace --name "${uniqueName}sender">"${uniqueName}ehsendkeys.json"

declare ehsendconnectionstring=$(cat ${uniqueName}ehsendkeys.json | jq -r .primaryConnectionString) 
echo sender app connection string=\"$ehsendconnectionstring\"