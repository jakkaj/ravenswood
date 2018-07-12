
function getparam {
    cat ./config.json | jq -r .$1
}

export ver=$(getparam ver)

export subscription=$(getparam subscription)

export loca=$(getparam loca)
export locb=$(getparam locb)

export a_location=$(getparam a_location)
export b_location=$(getparam b_location)

export sp_appid=$(cat ../acsengine/ClusterA/azure_sp.json | jq -r .appId)
export sp_password=$(cat ../acsengine/ClusterA/azure_sp.json | jq -r .password)

export a_rg=Ravenswood-$loca-$ver
export b_rg=Ravenswood-$locb-$ver

export a_vnet=RavneswoodVnet_$a_rg
export b_vnet=RavneswoodVnet_$b_rg

export kubeconfig_acs=../builds/$ver/acs_kubeconfig.json
export kubeconfig_aks=../builds/$ver/aks_kubeconfig.yaml


export kubeconfig_acs_latest=../builds/acs_kubeconfig.json
export kubeconfig_aks_latest=../builds/aks_kubeconfig.yaml