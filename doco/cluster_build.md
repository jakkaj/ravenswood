# Build and Deploy the Cluster

*Note* This guide is tailored for Microsoft Azure deployment, but could easily be adapted to run on other cloud providors or locally hosted Kubernetes clusters as most of the detail is Kubernetes native. 

## Two Clusters

This system is based around two geo-separated clusters (for warm fail-over) although it would be possible to run it without the second cluster. 

In this case (as the scripts are currently configured) an [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes) cluster is set-up in Sydney and an [acs-engine](https://github.com/Azure/acs-engine) based cluster is set up in Melbourne. 

### DevOps

The scripts herein are used to automatically set up the clusters either from a Linux terminal or from a VSTS server. 

### Configuration 

All configuration for the cluster build is stored in `/cluster/scripts/config.json`. 