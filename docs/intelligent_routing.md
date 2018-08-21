# Intelligent Routing


<!-- TOC -->

- [Intelligent Routing](#intelligent-routing)
    - [Routing for DevOps](#routing-for-devops)
        - [Decouple the route from the app](#decouple-the-route-from-the-app)
            - [Sidecars](#sidecars)

<!-- /TOC -->

There are a number of angles to view the benefits of [Istio](https://istio.io/docs/concepts/what-is-istio/)'s routing from in this system. From DevOps to fault testing to A/B testing to intelligent routing in the fullest.

## Routing for DevOps

Part of the power of this system is in the way deployments and versioning are managed. Deployments are immutable and cannot be changed after the fact. This means that to update the cluster, a new deployment must be created and applied. The new deployment will be running at the same time as the old deployment - meaning there needs to be a switch. 

Each component that is deployed in to the cluster will be a new version. The addresses of the deplpyed services are based on the version of the deployment which means that each new deployment comes with unique service endpoints. These new service addresses can be used to choose at runtime in the cluster where to route traffic!

### Decouple the route from the app

Inside the application (in a container, in a pod, in the cluster) a piece of code may want to call another service. For example it might try and hit up `http://svc1`. This will by default search out a service called `svc1` in the same Kubernetes namespace as where the pod is deployed. 

#### Sidecars
During deployment of a pod Istio will automatically attach another container in to the pod in a pattern known as the [Sidecar](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/) pattern which is essentially a way to configure pod composition in the cluster automatically (per namespace). 

During inititialisation the new sidecar will adjust the route tables of the pod to ensure that all traffic is routed through the sidecar. The sidecar also contains a proxy called [Envoy](https://www.envoyproxy.io/) which will intercept the traffic and route based on rules that are configured in the cluster - meaning those rules do not have to be configured or understood in the app itself. 

