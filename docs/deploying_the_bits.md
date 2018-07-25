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

# Scripts

The scripts to automatically apply the deployments are located at `/deployments/Scripts/`.

## Configs

These scripts invariably load config from `/deployments/Scripts/config.json` including the build version (`ver`) and build name (`build`). These will show up in the deployed asset names in the cluster - for example if it's ver:1 and build:test then ZooKeeper will show up as zk-test-1 in the cluster. 

The configs also configure the cluster secrets. Apply the settings creatd in [Getting Started](getting_started.md) here. These configs will be applied in the cluster as [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/). The Helm Chart that applies this secret is `/deployments/Helm/configs` with the secrets being applied by `/deployments/Helm/configs/templates/secrets.yaml`.

# Chart Operation

