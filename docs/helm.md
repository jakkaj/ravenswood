# Helm

This system is based heavily around [Helm](https://helm.sh/). It provides the mechanism to properly separate versions of code amongst other things. 

# Nuggets

Some nuggets from the Helm part of the project. Below these nuggets is the full explanation of the Helm Charts. 

## Versioning 

One important part of this arctehicture is the immutable and separate deployment goal. Helm helps achieve this goal by providing a strong template system which we can leverage to configure a deployment. 

Everything that is deployed in the system gets a host name based on the deployment version. 

Think about how Zookeeper needs to know where all the other Zookeeper nodes are. Additionally the node count needs to be configurable meaning it cannot be hard coded. The server addresses cannot be hard coded as they will change with the deployment version. 

Helm simplifies this by allowing values to be swapped and changed and utilised by the powerful Go Templates based system. 

This is the deployment configuration Helm Chart that all deployments will get. Because the deployments are immutable and well versioned it's easy to know which configuration belongs to which deployment. This file is located at `/deployments/Helm/configs/templates/configs.yaml`. 

```yaml
{{- $root := . -}}
apiVersion: v1
kind: ConfigMap
metadata:
 name: app-config-{{.Values.Version}}-{{.Values.Build}}
 namespace: default
data:
  nimbusnodes: | {{range $i, $e := until (int .Values.NimbusNodes)}}
    - nimbus-{{$root.Values.Version}}-{{$root.Values.Build}}-{{$i}}.nimbus-hs-{{$root.Values.Version}}-{{$root.Values.Build}}.default.svc.cluster.local
    {{- end }} 
  zookeepernodes: | {{range $i, $e := until (int .Values.ZookeeperNodes)}}
    - zk-{{$root.Values.Version}}-{{$root.Values.Build}}-{{$i}}.zk-hs-{{$root.Values.Version}}-{{$root.Values.Build}}.default.svc.cluster.local
    {{- end }} 
```
## Dynamic Settings

The associated `values.yaml` file includes 

```yaml
ZookeeperNodes: 3
NimbusNodes: 2
```

These values will be adjusted at runtime by the deployment scripts using the `helm --set` command (see [here](https://github.com/helm/helm/blob/master/docs/chart_best_practices/values.md) for more information). 

The `0.deploy_all_services.sh` script creates a `setter` variable.  

```bash
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

This variable is then passed in to all helm calls to dynamically set values in the helm deployments without having to modify files on the filesystem. 

```bash
echo "Update Configs"
helm template $setter -f ../Helm/configs/values.yaml ../Helm/configs | kubectl $kcommand -f -
```

- `helm template` will tell helm to generate the template locally, rather than apply it to the cluster (we want to apply via `kubectl` as it gives us more flexibility)
- `$setter` will send the variables in to the templating engine for replacement over the top of the `values.yaml` file
- `-f ../Helm/configs/values.yaml` passes in the base `values.yaml` file - this is to allow some settings to be stored in the values file and some dynamically provided by the scripts
- `../Helm/configs` the chart that is being used
- `| kubectl $kcommand -f -` pipes the data from the helm template build to `kubectl` without having to be written to the filesystem.  `$kcommand` is the parameter passed in from the terminal (`apply` `delete` etc.) to apply the script to create or delete the deployment. 




# Helm Charts

This section explains the chats this project uses. Each chart takes a version and applies it so that the items that are deployed ([StatefulSets](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/), [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/), [Services](https://kubernetes.io/docs/concepts/services-networking/service/), [Configs](https://kubernetes.io/docs/concepts/services-networking/service/), [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) [etc.](https://www.google.com.au/search?q=define+etc.&rlz=1C1CHBF_en-GBAU727AU727&oq=define+etc.&aqs=chrome..69i57j69i61j69i60l2j69i65j69i61.967j0j4&sourceid=chrome&ie=UTF-8#dobs=et%20cetera))

## Config

`/deployments/Helm/configs`

The config chart deploys deployment specific secrets and configuration. It includes settings that will be entered in the script config file as described in the [Deploying the Bits](deploying_the_bits.md) document. 

```yaml
Version: 2
Build: 136
ZookeeperNodes: 3
NimbusNodes: 2
eventhub_read_policy_key: "val_eventhub_read_policy_key"
eventhub_read_policy_name: "val_eventhub_read_policy_name"
eventhub_name: "val_eventhub_name"
eventhub_namespace: "val_eventhub_namespace"
cosmos_service_endpoint: "val_cosmos_service_endpoint"
cosmos_key: "val_cosmos_key"
cosmos_database_name: "val_cosmos_database_name"
cosmos_collection_name: "val_cosmos_collection_name"
```

