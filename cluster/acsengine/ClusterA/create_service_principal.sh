#!/usr/bin/env bash

acctList=$(az account list)

if ! [[ $acctList = *"tenantId"* ]]; then
    az login
else
    echo "You're already logged in"
fi

az account list | grep -e "name" -e "id"
echo "This script will help you create an Azure service principal"
read -p "Please enter your Azure subscription id: " -r

az account set --subscription "${REPLY}"
echo "{\"subs\":\"${REPLY}\"}" > "azure_subs.json"
echo $(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${REPLY}") > azure_sp.json
cat azure_sp.json | python -m json.tool
echo "Created successfully. Saved to azure_sp.json."
echo "Now run 'yo acsengine'"