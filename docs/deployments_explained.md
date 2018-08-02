# Deployments

This architecture is based around the concept of immutable, well versioned deployments. 

An immutable deployment, as the name suggests, is a deployment that cannot be changed after it has been deployed. This principal is applied in our other projects including our [ML training and scoring DevOps pipeline](https://github.com/jakkaj/ml-train-deploy-vsts-k8s).  

The principal drives some good system design principals:

- Good versioning strategy
- Separated deployments. Deploy the same code side by side in a different deployment
- Blue/Green Deployments as you cannot replace a deployment
- Separation of concerns including code versioning, routing and security
- Providence of all deployments including code, settings, cluster configuration and more
- End-to-end no humans directly affecting the software

## Helm

The orchestrator of these deployment versions is Helm. 

Each Helm template in the system contains a version and build. Take `/deployments/Helm/zookeeper` for example. Amongst other things the `values.yaml` file for this Helm Chart contains a version and a build. These values can be replaced at runtime by the scripts (see the [Helm](helm.md) document for more on that.)

```yaml
Version: coco
Build: 1
```

"coco" is the name of my product version - almost like a codename... its just an example! 

These values are applied by the chart templates.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: "zk-cs-{{.Values.Version}}-{{.Values.Build}}"
```

This will result in a deployment that creates services and pods with a common convention. 

Where Zookeeper will look like this:

```
pod/zk-2-coco-1-0                               1/1       Running   0          3m
pod/zk-2-coco-1-1                               1/1       Running   0          3m
pod/zk-2-coco-1-2                               1/1       Running   0          3m
```

The services might look like this:

```
pod/svc1-v1-2-coco-1-55dc7d88fb-7md4p           2/2       Running   0          2m
pod/svc1-v2-2-coco-1-74f9547f6d-r69fw           2/2       Running   0          2m
```

These versions can be passed in as configuration to the pods so they know where to find things. 

## Layers of Deployments

### Outer Deployment

When a version is iterated upon, and entirely new version of the streaming processing pipeline including ZooKeeper, Nimbus and the supervisors will be deployed. This means they can be deployed side-by-side, in a second cluster, on a developer machine or at a time long in the future. 

Whilst this is good, it doesn't make sense to deploy the entire Storm cluster if we just want to upgrade a service. Or experiment with different services, or use [intelligent routing](intelligent_routing.md) to choose who to route between different versions of a service. 

This brings the need for a second layer of deployments. 

## Inner Deployment

Full cluster and services deployments aside, we can deploy new versions of the same service side-by-side in a cluster by relying on the Kubernetes labelling and routing features. 

```yaml
template:
    metadata:
      labels:
        app: "svc1-{{.Values.Version}}-{{.Values.Build}}"
        version: v1
```

This is a sample from the `/deployments/Helm/services/templates/s1v1.yaml` file. It gives the service a pod name and a version. Deploying the same item again will either error (if using `kubectl create`) or will update it (if using `kubeclt apply`). 

`s1v2.yaml` has one small change: `version` is set to v2. This will result in two version of the same pod being deployed in to the cluster. 

```
pod/svc1-v1-2-coco-1-55dc7d88fb-7md4p           2/2       Running   0          2m
pod/svc1-v2-2-coco-1-74f9547f6d-r69fw           2/2       Running   0          2m
```

The challenge then is how do we use one of these?

## Route using Services

An option might be to route using Kubernetes services. Services can have a solid name such as `svc1-2-coco-1`. Services choose which thing they route to based on [label selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). 

```yaml
selector:
    app: "svc1-{{.Values.Version}}-{{.Values.Build}}"
    version: v1
```

Altering this to v2 will route all traffic to v2 without having to tell the calling code which service they are looking for. They simply always call `http://svc1-2-coco-1`. 

This method is great - but it's not as good as it gets. 

## Route using Istio

Istio is a service mesh system that does many things - one of which is routing. 

Using Istio we can route between different services easily and intelligently. This includes traffic splitting, intelligent routing based on headers and more. See the [intelligent routing](intelligent_routing.md) document for more. 

# Blue/Green and More

This deployment strategy allows for complex DevOps scenarios such as blue/green and others. 

For example, a new version of a service may be deployed in to the cluster via the "Inner" deployment method. Later a release could be performed that modifies the cluster configuration to route all traffic to that service from v1 to v2... all without any app in the cluster knowing about it. 

It's a very clean separation of concerns regarding complex application routing scenraios. 