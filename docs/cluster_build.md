# Prepare for Deployment

<!-- TOC -->

- [Prepare for Deployment](#prepare-for-deployment)
    - [Two Clusters](#two-clusters)
    - [DevOps](#devops)
    - [Configuration](#configuration)
    - [Set Up acs-engine Access](#set-up-acs-engine-access)
        - [Set up new SSH keys](#set-up-new-ssh-keys)
        - [Create a new Service Principal](#create-a-new-service-principal)
- [Deploy the Cluster](#deploy-the-cluster)
    - [Scripts](#scripts)
        - [0.runall.sh](#0runallsh)
        - [1.create_networks.sh](#1create_networkssh)
        - [2.a.create_aks.sh](#2acreate_akssh)
        - [2.b.create_acsengine.sh](#2bcreate_acsenginesh)
        - [3.config_cluster.sh](#3config_clustersh)
- [Kubectl Configurations](#kubectl-configurations)

<!-- /TOC -->

*Note* This guide is tailored for Microsoft Azure deployment, but could easily be adapted to run on other cloud providers or locally hosted Kubernetes clusters as most of the detail is Kubernetes native. 

[Watch the Video](https://youtu.be/H5e4Mq_FzzA).

## Two Clusters

This system is based around two geo-separated clusters (for warm fail-over) although it would be possible to run it without the second cluster. 

In this case (as the scripts are currently configured) an [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes) cluster is set-up in Sydney and an [acs-engine](https://github.com/Azure/acs-engine) based cluster is set up in Melbourne. 

## DevOps

The scripts herein are used to automatically set up the clusters either from a Linux terminal or from a VSTS server. 

You can use the following script with small modifications in VSTS

```yaml
resources:
- repo: self
queue:
  name: Hosted Linux Preview
  condition: succeeded()
#Your build pipeline references the ‘version’ variable, which you’ve selected to be settable at queue time. Create or edit the build pipeline for this YAML file, define the variable on the Variables tab, and then select the option to make it settable at queue time. See https://go.microsoft.com/fwlink/?linkid=865971
steps:
- bash: . 'cluster/acsengine/installacsengine.sh' 
  displayName: Bash Script

- task: tsuyoshiushio.k8s-endpoint.downloader-task.downloader@1
  displayName: downloader 
  inputs:
    k8sService: 'AKS-k8s-test'
    IstioVersion: 0.8.0
    helmVersion: 2.9.1

- task: jakkaj.vsts-yaml-writer.custom-build-release-task.YamlWriter@0
  displayName: YamlWriter 
  inputs:
    file: 'cluster/scripts/config.json'
    set: 'ver=''$(version)-$(Build.BuildNumber)''
    json: true

- task: AzureCLI@1
  displayName: Azure CLI scripts/0.runall.sh
  inputs:
    azureSubscription: 'Jordo Microsoft Azure Internal Consumption (e39a92b5-b9a4-43d1-97a3-c31c819a583a)'
    scriptPath: 'cluster/scripts/0.runall.sh'
    workingDirectory: scripts

- task: PublishBuildArtifacts@1
  displayName: Publish Artifact: clusterbuild-$(version)-$(Build.BuildNumber)
  inputs:
    PathtoPublish: '$(Build.Repository.LocalPath)/builds'
    ArtifactName: 'clusterbuild-$(version)-$(Build.BuildNumber)'
```

Too Easy! See [this video](https://youtu.be/H5e4Mq_FzzA) for a visual demo of this. 


## Configuration 

All configuration for the cluster build is stored in `/cluster/scripts/config.json`. 

```json
{
    "ver":"somedemo-1",
    "subscription": "<your subs id> | will look like a guid",
    "loca": "Syd",
    "locb": "Melb",
    "a_location": "australiaeast",
    "b_location": "australiasoutheast"
}
```

- **ver**: the name the cluster will get once it is deployed
- **subscription**: your Azure Subscrption Id. You'll need to be able to access this subscription from the 
- **loca and locb**: Friendly names of the locations. These names will be used in combination with the `ver` field to create the resources and groups. 
- **a_location and b_location**: Azure region names to deploy to

## Set Up acs-engine Access

The acs-engine templates have been pre-generated to save time. There are a couple of setting files that need to be updated - the SSH keys and the service principal ID and password. 

### Set up new SSH keys

The acs-engine templates use pre-generated SSH keys for access to the cluster later (i.e. ssh in to the master node). 

These keys are stored in `/cluster/acsengine/ClusterA/keys`. You'll need to replace these files for security reasons. 

To generate new keys:

```bash
ssh-keygen -f <filename/>
```

Once that key is generated, copy and paste the .pub keyfile contents in to `/cluster/acsengine/ClusterA/buildacs.template.json` in to the field named `keyData` (towards the bottom of the file). 

### Create a new Service Principal

Follow the insturctions [here](https://github.com/Azure/acs-engine/blob/master/docs/serviceprincipal.md) to create a new service principal, then copy the id and password in to the same `buildacs.template.json` file in the `clientId` and `secret` fields. 

There is a helper script in `/cluster/acsengine/ClusterA/create_service_principal.sh` which you can use / investigate. 

# Deploy the Cluster

Cluster deployment is achieved using a series of scripts located under `/cluster/scripts`. 

## Scripts

### 0.runall.sh

This script runs all the required scripts in the correct order. It will run scripts in parallel where appropriate. 

Run this script to set up your clusters. 

### 1.create_networks.sh

- Sets the subscription 
- Creates the resource groups
- Creates the storage account (accessible from both clusters)
- Creates VNETs in both geo regions
- Creates a VNET peer between the two networks for cross cluster communication

### 2.a.create_aks.sh

- Runs the ARM deployment of the AKS cluster based on `/arm/kube-managed.json` config options
- Extracts the AKS kubectl configs and stores them in `/builds/$ver/aks_kubeconfig.yaml`

### 2.b.create_acsengine.sh

- Generates the ARM templates using acs-engine
- Runs the ARM deployment of the acs-engine cluster based on `../builds/$ver/$resourcegroup/azuredeploy.parameters.json` config options
- Extracts the acs-engine kubectl configs and stores them in `/builds/$ver/acs_kubeconfig.json`

### 3.config_cluster.sh

Configures the clusters using Kubectl. 

- Installs the cluster config maps. Each cluster gets a custom map that identifies its status as the primary or seconday cluster. Config map also includes the access information for the storage accounts.
- Install [Istio](https://istio.io/docs/concepts/what-is-istio/overview/)
- Installs [Helm](https://helm.sh/)
- Sets up some basic routes in Istio using this file: `/kube/istioctl.yaml`.

These scripts will take approximately 10-20 minutes to complete.




# Kubectl Configurations

The build process will output the `kubecfg` files for both clusters:

- The ACS Kubectl configs are stored in `/builds/$ver/acs_kubeconfig.json`
- The AKS Kubectl configs are stored in `/builds/$ver/aks_kubeconfig.yaml`
