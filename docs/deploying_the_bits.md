<!-- TOC -->

- [Deployment](#deployment)
- [The Components](#the-components)
- [Scripts](#scripts)
    - [Configs](#configs)
    - [Run the Scripts](#run-the-scripts)
        - [0.deploy_all_services.sh](#0deploy_all_servicessh)
        - [Apply the Script](#apply-the-script)
        - [Delete all services from both clusters](#delete-all-services-from-both-clusters)
        - [Script CLI parameters](#script-cli-parameters)
- [Chart Operation](#chart-operation)
        - [1.deploy_toplology.sh](#1deploy_toplologysh)

<!-- /TOC -->

# Deployment



Once the clusters are created and running it's time to deploy the software. 

For the time being you can deploy the pre-built test version of the code, before making modifications yourself to run your own pieces.

These components are pre-build Docker images that are found in the `/deployments/docker` folder. 

The [Docker](docker.md) document contains instructions and other details about the containers that are used. 

The various components of the system are deployed via [Helm Charts](https://github.com/helm/charts). Helm is mostly used for its templating capability - deployments are applied via `kubectl` not `helm install`. 

Helm has a "template" option that allows it to generate the template locally, and Kubectl has a method that allows it to pipe in the templat rather than apply from a file. 

```bash
helm template $setter -f ../Helm/configs/values.yaml ../Helm/configs | kubectl $kcommand -f -
```

This command asks Helm to process the template located at `../Helm/configs` using the values file located at `../Helm/configs/values.yaml`, using addition settings passed in by `$setter` (more on that soon). It then pipes it in to kubectl using `$kcommand` (which is passed in from the terminal and could be "apply" or "delete") which applies that file to the cluster. 

# The Components

Each component of the system is detailed in the [System Components](system_components.md) file. They are ZooKeeper, Nimbus, the enrichment test services, configs and secrets, heartbeat and Storm UI. 

# Scripts

The scripts to automatically apply the deployments are located at `/deployments/Scripts/`.

Before running the scripts, ensure you update the config file. 

## Configs

These scripts invariably load config from `/deployments/Scripts/config.json` including the build version (`ver`) and build name (`build`). These will show up in the deployed asset names in the cluster - for example if it's ver:1 and build:test then ZooKeeper will show up as zk-test-1 in the cluster. 

The configs also configure the cluster secrets. Apply the settings creatd in [Getting Started](getting_started.md) here. These configs will be applied in the cluster as [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/). The Helm Chart that applies this secret is `/deployments/Helm/configs` with the secrets being applied by `/deployments/Helm/configs/templates/secrets.yaml`.

## Run the Scripts

All the services and other deployable assets (aside from the actual Storm topology) are deployed by the script `/deployments/Scripts/0.deploy_all_services.sh`. 

This script loads configs by calling `loadconfigs.sh` before calling `/deployments/Scripts/lib/services.sh`. The files under the `lib` folder should not be called directly as they expect certain environment variables to be prepared (as done by `0.deploy_all_services.sh` calling `loadconfig.sh` calling `services.sh`). 


### 0.deploy_all_services.sh

Deploys the various Helm Charts based under /Helm. See [System Components](system_components.md) for more detail on how these operate. 

- Helm/configs

- Helm/storage

- Helm/heartbeat

- /Helm/zookeeper

- Helm/nimbus

- Helm/supervisor

- Istio/base

- Helm/services


### Apply the Script

To apply switch to `/deployment/Scripts'. 

```bash
0.deploy_all_services.sh create
```


### Delete all services from both clusters

```bash

```

### Script CLI parameters

The scripts can take parameters to indicate to create or delete services. This functionality is implemented in `configkube.sh`


```bash

if [ "$1" == "create" ]; then
    export kcommand='create'
elif [ "$1" == "delete" ]; then
    export kcommand='delete'
elif [ "$1" == "apply" ]; then
    export kcommand='apply'
fi
```

This parameter is then passed in to all `kubectl` commands. 

# Chart Operation

Each of the charts has a `values.yaml` file that outlines the values (with samples) that will be used by the template generation. These values are modified by the scripts during deployment. 

This is done in the `0.deploy_all_services.sh` script. It loads configs then builds the `$setter` and `$storage_account` values amongst others. 

```bash
export storage_account=$(kubectl get configmap ravenswoodconfig -o json | jq -r .data.storage)

export setter="--set Version=$ver --set Build=$build --set StorageAccount=$storage_account \
    --set eventhub_read_policy_key=$eventhub_read_policy_key \
    --set eventhub_read_policy_name=$eventhub_read_policy_name \
    --set eventhub_name=$eventhub_name \
    --set eventhub_namespace=$eventhub_namespace \
    --set cosmos_service_endpoint=$cosmos_service_endpoint \
    --set cosmos_key=$cosmos_key \
    --set cosmos_collection_name=$cosmos_collection_name \
    --set cosmos_database_name=$cosmos_database_name"
```

These values are then passed in to the `helm template` command as command line based settings. 

```bash
helm template $setter -f ../Helm/zookeeper/values.yaml ../Helm/zookeeper | kubectl $kcommand -f -
```

This command pipes the output of the `helm template` command in to `kubectl` directly without needing to be written to a file. 

### 1.deploy_toplology.sh

Once the services are deployed, ZooKeeper, Nimbus, the services, configs, heartbeat and Storm UI will be deployed. The next stage is to deploy a test topology

