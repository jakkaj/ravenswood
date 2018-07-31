<!-- TOC -->

- [Docker Containers](#docker-containers)
    - [Build the Containers](#build-the-containers)
- [Storm Containers](#storm-containers)
    - [Base](#base)
    - [Nimbus](#nimbus)
    - [Supervisor](#supervisor)
    - [Topology](#topology)
    - [Storm UI](#storm-ui)
- [Services](#services)
    - [Service 1](#service-1)
    - [Service 2 and 3](#service-2-and-3)
    - [Basic Environment Writer](#basic-environment-writer)

<!-- /TOC -->

# Docker Containers

This project makes heavy use of Docker containers. This section goes through each of the containers, where they are and what they do. 

The Dockerfile for each container is provided so you can review, modify and rebuild for your needs. 

A shout out to [Matthew Farrellee](https://github.com/mattf) for providing a great starting place for these Dockfiles. 

## Build the Containers

The containers can be built by modifying and running `deployments/Docker/buildall.sh` and `pushall.sh`. Update these with your own Container Registry like [Docker Hub](https://hub.docker.com/) or [Azure Container Registry](https://azure.microsoft.com/en-gb/services/container-registry/). 

# Storm Containers

Containers are located under `deployments/Docker`. 

## Base

`deployments/Docker/base/Dockerfile`

The base image is used by all the other Storm images. 

It installs things like Python, JRE, tools like Curl and Wget to help you debug stuff. 

The base image includes `deployments/Docker/base/configure.sh` which is called by the startup script in each derived container. It helps set up the Storm config of Nimbus and Zookeeper nodes and is part of the strategy for making the Zookeeper and Nimbus node count dynamically configurable. 

## Nimbus

`deployments/Docker/nimbus/Dockerfile`

Each of the Storm based containers will run `start.sh` which will do different things depending on the setup of the cluster. 

Once configured, the Nimbus container will run `exec bin/storm nimbus` to fire up the container as a Nimbus node. This will then seek out the Zookeeper servers to try and elect a leader before becoming ready to feed out jobs to the supervisors. 

Nimus is deployed as part of a [StatefulSet](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/) as is Zookeeper.

## Supervisor

`deployments/Docker/supervisor/Dockerfile`

This container is similar to the Nimus one, but instead of starting a Storm Nimbus node it starts supervisor nodes. This container is designed to be deployed as many times as needed via the [replicas](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#Replicas) setting of a Kubernetes deployment. Note - the supervisors are not part of a StatefulSet unlike Zookeeper and Nimbus. 

## Topology

`deployments/Docker/topology/Dockerfile`

A core tenet of this system is immatable deployments. The cluster is not modified, only new deployments are added (or removed). To this end, event deploying a new Storm topology is done via a deployment. 

This container when built takes a pre-built Storm topology. It's startup script will deploy the topology. This is much better than applying a command to a pod running in the cluster as it's repeatable and has provenance. 

```bash
exec bin/storm jar "./StormEnrichmentTopology-1.0-SNAPSHOT.jar" \
    org.apache.storm.flux.Flux \
    --remote \
    --env-filter \
    "./enricher-env.yaml"
```

The dependency files are located in `built`. 

The files to modify and rebuild the topology are located under `deployments/Storm/Topologies/StormEnrichmentTopology`. Once rebuilt, copy the JAR in to the `built` folder and rebuild and redeploy the Topology container for deployment in to the cluster. 

## Storm UI

`deployments/Docker/UI/Dockerfile`

This container deploys the Storm UI. Once deployed, it will fire up the Storm UI web interface. The [Helm Chart](helm.md) deployment adds a public service IP to access the UI. 

# Services

The sample enrichment services have a second separate set of containers and are located in `/services`. 

These services are deployed in the cluster along side the Storm system. They are versionable - and the default deployment will send in two versions of each for usage during the [intelligent routing](intelligent_routing.md) demo. 

The services are [.NET Core](https://www.microsoft.com/net/download/dotnet-core/2.1) MVC apps. There are two types. 

As the Storm Bolts call the service they pass in the [emitted event](sending_test_events.md) and any previous enrichments as a posted value. They also pass in the previous enrichment fields and values as headers so Istio can [intercept them](intelligent_routing.md).  

## Service 1

Events that are emitted include a User id. This value is taken by the first service and enriched by segmenting the user in to one of two segments. This segmentation is then used later by the [intelligent routing](intelligent_routing.md).

Each service also reflects back an environment variable called `WRITE_BACK` which is passed in from the Kubernetes deployment [Helm Chart](helm.md).

## Service 2 and 3

These services only reflect back environment variables - `WRITE_BACK`, `WRITE_FIELD` and `CLUSTER`. Cluster is the value of the cluster that the service is running in, as grabbed from the config map that is created when the cluster is [built](cluster_build.md). This helps to visualise the cluster fail over in action as the cluster goes from a to b during the failure event. 

The idea of this environment variable reflection is that you can use the same container multiple times to reflect different values - i.e. publish a container as V1 and V2, all that changes it the reflected value - which is handy for demonstrating [intelligent routing](intelligent_routing.md) later.

## Basic Environment Writer

A simple form of this environment reflection container is available on GitHub [here](https://github.com/jakkaj/basic-env-write). 


