# Version 5.x

## Summary
* Improved config flexibility, e.g.:
  * All resources in same tfstate
  * Identity resources only/enabled individually
  * Network resources only/enabled individually
  * Cluster with existing network VCN/subnets/NSGs
  * Cluster & isolated NSGs with existing network VCN/subnets
  * Workers with existing cluster/network
  * Workers with tag-based group/policy for Cluster Autoscaler, ...
  * Operator with existing cluster & group/policy for cluster access
* **Workers:** resource type configuration (Self-Managed, Virtual)
  * `mode="node-pool"`
  * ***New*** `mode="virtual-node-pool"`
  * ***New*** `mode="instance"`
  * ***New*** `mode="instance-pool"`
  * ***New*** `mode="cluster-network"`
* **Workers:** merge/override global & pool-specific for most inputs
* **Network:** Referential NSG security rule definitions
* Sub-module refactor
    * `iam`: Dynamic groups, policies, defined tags
    * `network`: VCN, subnets, NSGs, DRGs
    * `bastion`: Bastion host for external VCN access
    * `cluster`: OKE managed Kubernetes cluster
    * `workers`: Compute pools for cluster workloads with configurable resource types
    * `operator`: Operator instance with access to the OKE cluster endpoint
    * `utilities`: Additional automation for cluster operations performed by the module
    * `extensions`: Optional cluster software for evaluation

## Status

`Pre-release / Beta`

Core features of the module are working.

Some features under `utilities` need re-implementation/testing:
* OCIR
* Worker pool `drain`

Documentation in progress.

## Breaking changes
* Input variables
* **Pending**

## Migration
**Pending**

# Version 4.x

## Summary
* ...?

## Status

`Released`

This is the latest supported version of the module.

## Migration
**Pending**

# Version 3.x
## Summary

## Status
`Maintenance`

## Migration
**Pending**

# Version 2.x
## Status
`Maintenance`

# Version 1.x
## Status
`Unsupported`
