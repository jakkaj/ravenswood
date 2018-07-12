
function getparam {
    cat ./config.json | jq -r .$1
}

export ver=$(getparam ver)
export build=$(getparam build)

#this printf stuff is to prevent erroneous newlines and whitepace being encoded
export eventhub_read_policy_key=$(printf "%s" $(getparam eventhub_read_policy_key) | base64 -w 0)
export eventhub_read_policy_name=$(printf "%s" $(getparam eventhub_read_policy_name) | base64 -w 0)
export eventhub_name=$(printf "%s" $(getparam eventhub_name) | base64 -w 0)
export eventhub_namespace=$(printf "%s" $(getparam eventhub_namespace) | base64 -w 0)
export cosmos_service_endpoint=$(printf "%s" $(getparam cosmos_service_endpoint) | base64 -w 0)
export cosmos_key=$(printf "%s" $(getparam cosmos_key) | base64 -w 0)
export cosmos_database_name=$(printf "%s" $(getparam cosmos_database_name) | base64 -w 0)
export cosmos_collection_name=$(printf "%s" $(getparam cosmos_collection_name) | base64 -w 0)


export kubeconfig_aks=builds/$build/aks_kubeconfig.yaml
export kubeconfig_acs=builds/$build/acs_kubeconfig.json