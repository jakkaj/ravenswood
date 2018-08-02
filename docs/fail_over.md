# Fail Over

This reference design has the capability to fail over to a second cluster. There are two approaches to this described here: [Virtual Network Peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) and [Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction). 

<!-- TOC -->

- [Fail Over](#fail-over)
- [The problem](#the-problem)
    - [High Availability](#high-availability)

<!-- /TOC -->

# The problem

To create a system that is highly available (HA) and disaster recoverable (DR). 

## High Availability

HA in this system is created via [StatefulSets](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/), [PodDisruptionBudgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#how-disruption-budgets-work) and [updateStrategies](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/#updating-statefulsets) in combination with [Azure Availability Sets](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability). 

See [Helm](helm.md) for more information on how those are implemented. 

