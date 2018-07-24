

# Required Software

## Linux OS

The scripts and techniques employed in this system are designed to run on Linux system (or build agent) or the Windows based [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10). 

### Use the Container  

Rather than configure a system with all the detailed requirements, you can just build the Dockerfile in /cluster/Dockerfile. 

Even if you don't decide to do this you can use that file as a reference for the commands to get the environemnt up and running. 

- Switch to /cluster. 
- `docker build -t clusterbuilder .`
- `docker run -it clusterbuilder bash` to log in and start running!

### Linux Software
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


