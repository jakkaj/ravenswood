



<!-- TOC -->

- [Operating System](#operating-system)
    - [Use the Container](#use-the-container)
    - [Linux Software](#linux-software)
- [Azure Services](#azure-services)
    - [General Resource Group](#general-resource-group)
    - [Event Hubs](#event-hubs)

<!-- /TOC -->

# Operating System

The scripts and techniques employed in this system are designed to run on Linux system (or build agent) or the Windows based [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10). 

## Use the Container  

Rather than configure a system with all the detailed requirements, you can just build the Dockerfile in /cluster/Dockerfile. 

Even if you don't decide to do this you can use that file as a reference for the commands to get the environemnt up and running. 

- Switch to /cluster. 
- `docker build -t clusterbuilder .`
- `docker run -it clusterbuilder bash` to log in and start running!

## Linux Software
*Configure your machine or build environment*

These instructions are geared towards Ubuntu.

Start with `sudo apt-get update`. 

- Azure CLI - [Instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- Kubectl - [Instuctions](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)
- [JQ](https://stedolan.github.io/jq/) - `sudo apt-get install jq`
- ACS Engine - [Instructions](https://github.com/Azure/acs-engine/blob/master/docs/acsengine.md#install-acs-engine)
- Node.js - [Instructions](https://nodejs.org/en/download/package-manager/). Get the latest version. 
- [Yamlwriter](https://www.npmjs.com/package/yamlw) - `npm install -g yamlw`
- curl and wget - `sudo apt-get install curl wget -y`
- nano - `apt-get install nano -y`
- [kubecfg](https://www.npmjs.com/package/kubecfg) for easier cluster management - `npm install -g kubecfg`


# Azure Services

## General Resource Group   

In the azure portal create a new general resource group to hold durable resources. Where the cluster build scripts will create specially named resource groups - you'll need a resource group to hold things like the database, storage and Event Hubs. 

Create a new resource group, name it something generic and meaningful.

## Event Hubs

You'll need an [Azure Event Hub](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-about) to produce the input stream that is read by the Storm spout. 

- Create a new [Event Hubs](https://ms.portal.azure.com/#create/Microsoft.EventHub) in the Azure Portal
- Select Basic Pricing for a start
- Add it to the general resource group you created
- Create it in the same region as the first cluster (in the example it's Sydney)
- Set the Throughput units to a low number. 1 should be find during development
- Leave Auto-Inflate disabled to avoid any surprises in billing
- Once created, navigate to the new Event Hub
- Click on Event Hubs under ENTITIES sub-section and add a new Event Hub (Two Partitions, leave the rest default)
- Once that's created, navgiate to the new Event Hub and click on Shared access policies
- Add a new one called "reader"
- Select the Listen checkbox and leave the other two blank, and copy out the primary key and the connection string for later usage





