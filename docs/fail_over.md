# Fail Over

This reference design has the capability to fail over to a second cluster. There are two approaches to this described here: [Virtual Network Peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) and [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction). 

<!-- TOC -->

- [Fail Over](#fail-over)
- [The problem](#the-problem)
    - [Video](#video)
    - [High Availability](#high-availability)
- [Streaming Systems Versus Web Style System](#streaming-systems-versus-web-style-system)
    - [Stream Semantics](#stream-semantics)
- [Disaster Recovery](#disaster-recovery)
- [Disaster Recoverable Products](#disaster-recoverable-products)
    - [Cosmos Database](#cosmos-database)
    - [Event Hubs](#event-hubs)
    - [Azure Storage](#azure-storage)
- [Your Code](#your-code)
    - [Ensuring the Code is Running](#ensuring-the-code-is-running)
    - [Pre-deploy the Storm Cluster](#pre-deploy-the-storm-cluster)
    - [Block Deployments with an Init Container](#block-deployments-with-an-init-container)
    - [Heart Monitor](#heart-monitor)
- [Virtual Network Peering](#virtual-network-peering)
    - [Warning: Internal Load Balancers](#warning-internal-load-balancers)
- [Trigger the Fail Over](#trigger-the-fail-over)

<!-- /TOC -->

# The problem

To create a system that is highly available (HA) and disaster recoverable (DR). 

## Video

Watch [the video](https://www.youtube.com/watch?v=6iu5u4JTvcI) to see fail over and [this video](https://www.youtube.com/watch?v=WtsCKkoK-18) to see fail back. 

## High Availability

HA in this system is created via [StatefulSets](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/), [PodDisruptionBudgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#how-disruption-budgets-work) and [updateStrategies](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets) in combination with [Azure Availability Sets](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability). 

See [Helm](helm.md) for more information on how those are implemented. 

The point here though is around DR - what happens when a cluster vaporises?

# Streaming Systems Versus Web Style System

Consider an incoming request from a user in a web style system. That request could transit a [traffic management service](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview) that will route the traffic to the most appropriate service. If that traffic manager is smart enough, it will know if the proposed target of the traffic is running. If it detects the target system is running it can route the traffic to a different (geo) location. 

With streaming systems this is not so simple - events are generated as part of a stream (like [Kafka](https://kafka.apache.org/) or [Event Hubs](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-about)). These events are then pulled by the system that is using them (in real-time as they arrive perhaps). Due to this - there is not an opportunity to route these events to another location for processing in a way the traffic manager may. 

## Stream Semantics

DR and HA requirements may change depending on the semantics - "at least once" or "exactly once". 

At least once means the event will be processed at least once, but could be processed more than that. The problem of cleaning up is handled by later batches and the reading side will allow for the possibility that there could be more than one record the same (it will query in latest date or format for example). This semantic makes it easier to fail over and back again to a new cluster without 

Only once means a message will be processed once or not at all. This semantic makes it harder to fail over and back as two systems running at the same time (i.e. primary and backup during fail back) might process the same message twice depending on dequeing semantics and where/how the stream offset is stored. By default the offset information is stored in Azure Storage - which is why you need to supply an Azure Storage account when setting up an Event Hubs consuming application. 

```json
{
    "Offset":"774464",
    "SequenceNumber":3462,
    "PartitionId":"1",
    "Owner":"xxxx",
    "Token":"xxx",
    "Epoch":2
}
```

As you can imagine it could be hard to synchronise this between two systems pulling from the same queue. 

# Disaster Recovery

DR has many meanings - in this case we want a smooth transition to a backup system if the primary system becomes inoperative. There are a bunch of details including [recovery point objective](https://en.wikipedia.org/wiki/Recovery_point_objective) and [recovery time objective](https://en.wikipedia.org/wiki/Recovery_time_objective) that often go in to DR planning. 

It may seem nice to have two separate systems running and processing events. This active/active system could work, although the second system may be located in a geo region far away, and latency could be an issue.  

Where active/active is not supported, the DR system might be considered to be operating in a degraded state which is undesirable unless it's the last resort. The backup system might have too much latency, or database latency and concurrency may be an issue. 

Regardless of why - this document presents a couple of methods for fail over. 

For the sake of this document we're taking the approach that an entire data center goes out. That is - all services, VM, database, Event Hubs etc go. This includes active/active in the same data center. It includes [availability sets](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/regions-and-availability) going out.  

# Disaster Recoverable Products

Whilst we're in charge of making sure our code is disaster recoverable, we can rely on a couple of Azure Products to manage data recovery for us. In this system - stateful systems always use managed services if available. For example - we'd not store a Cassandra database in a Kubernetes cluster if there is a comparative managed service like Cosmos Database availabile. 

## Cosmos Database

[Cosmos Database](https://docs.microsoft.com/en-us/azure/cosmos-db/distribute-data-globally) allows for geo distribution out of the box. If one region goes out, another region can take over as master an allow the app to continue. It can be read from any region at any time. 

## Event Hubs

[Event Hubs](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-geo-dr) has a disaster recovery option as well. See this [sample](https://github.com/Azure/azure-event-hubs/tree/master/samples/DotNet/GeoDRClient) on GitHub. 

## Azure Storage

[Geo-redundant](https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy-grs) in Azure Storage help protect against regional issues. 

# Your Code

These products are great, but how do you deploy your code for recovery. Web style code can easily be deployed in systems such as Kubernetes or the [Azure App Service](https://azure.microsoft.com/en-au/services/app-service/) across regions with [Azure Traffic Manager](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview) routing incoming requests to the appropriate region.  But what happens when you're code is not receiving web requests, but is instead pulling from a queue?

A reminder that this repo is talking about code hosted in a Kubernetes cluster. 

## Ensuring the Code is Running

Given we don't want code to be running in the second region until we've triggered the fail over state we still need to ensure the code is deployed and ready in the second region. Also consider the event hub namespace we're pulling from will be active and ready - i.e. if our code runs it will start pulling... so the code needs to be ready, but not fully activated. 

## Pre-deploy the Storm Cluster

In our use case we have a Storm cluster, but it could be other technologies. The concept here is that we deploy the Storm Cluster and any subsequent deployments to both the primary and secondary clusters at the same time - each cluster will have all code, configs, Istio routes etc. applied at the same time. 

This allows for a few things

- We can ensure the code will deploy
- Special considerations such as anti-pod affinity and other settings could prevent deployments in an unexpected manner, so we need to make sure the code is running and has "reserved" its place in the cluster
- All images are pulled and ready - will be primed for a warm fail over
- Could run test messages through the system to check it's ready to rock

## Block Deployments with an Init Container

The entire cluster is deployed and started except for the Storm Topology. Its pod is deployed but blocked from starting by an [Init Container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) as described in greater detail in the [Helm](helm.md) document. 

## Heart Monitor

The app in the init container is `/apps/Monitor/HeartMonitorFS`. This app has fed to it the cluster id (a or b) as well as the folder to monitor. 

```csharp
var file = Environment.GetEnvironmentVariable("HEART_BEAT_FOLDER");

var thisCluster = Environment.GetEnvironmentVariable("THIS_CLUSTER");
var thatCluster = Environment.GetEnvironmentVariable("THAT_CLUSTER");
```

If its being loaded in "cluster A" the monitor app will exit with a code of 1 indicating that the Topology pod should load and deploy the Storm Topology.

```csharp
 if(thisCluster == "a"){
    Environment.Exit(0);
}
```

However if the cluster id is "b" then the app will loop, monitoring the heart beat file being generated by `/apps/Monitor/HeartBeatFS` in the remote cluster. It compares the current date with that in the file. If the date is old enough it's considered a flat line and the monitor app will exit and allow the Storm Topology pod to load and deploy. 

```csharp
while(true){
    try{                   
        
        var data = File.ReadAllText(fi.FullName);

        var parsed = new DateTime(Convert.ToInt64(data));
        var utc = DateTime.SpecifyKind(parsed, DateTimeKind.Utc);

        if (DateTime.UtcNow > utc.AddSeconds(10))
        {
            Console.WriteLine("Other cluster update too old - flatlining");
            //exit with 0 to ensure the initContainer allows the waiting containers to spin up
            Environment.Exit(0);
        }
        
        Console.WriteLine($"{DateTime.Now.ToLongDateString()} {DateTime.Now.ToLongTimeString()} Remote host updates within normal operating parameters");

        Thread.Sleep(5000);
    }catch(Exception ex){
        Console.WriteLine(ex);
    }
}
```

This mechanism uses [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux) mounted in to the Linux File system as a `/mnt` style path - which is easily accessible between geo locations. It's not recommenced to load large amounts of data between regions - but this use case the data is miniscule. 

Watch [the video](https://www.youtube.com/watch?v=6iu5u4JTvcI) for a demonstration of this in action. 
 This [video](https://www.youtube.com/watch?v=WtsCKkoK-18) demonstrates the fail back. 

# Virtual Network Peering

The cluster set up code will create clusters in two regions, each within a custom Virtual Network. It will then peer them together. 

The file `/cluster/scripts/1.create_networks.sh` performs this work. 

```bash
az network vnet create --name $a_vnet \
    --location $a_location --resource-group $a_rg \
    --address-prefix 192.168.210.0/24\
    --subnet-name default\
    --subnet-prefix 192.168.210.0/24 &
```

```bash
az network vnet peering create --resource-group $a_rg \
                                --name $a_vnetpeername \
                                --vnet-name $a_vnet \
                                --remote-vnet-id $vnet_b_id \
                                --allow-vnet-access &
```

The peering is performed from each side (vNET A and B) before the peering is complete. Once this occurs the two clusters can talk to each other. 

Using this communication method might be another way of cluster to cluster communication including heartbeats. 

## Warning: Internal Load Balancers
Be aware that internal load balancers will not allow communication from another vNET even if it's peered. 

# Trigger the Fail Over

In this system, the fail over can be caused by killing the heartbeat pod. This is not truly representative of the system processing messages. An alternative method might be to monitor the Event Hubs queue offset file to ensure it's moving along - or to directly monitor the storm cluster itself. 

