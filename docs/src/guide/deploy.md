# Deploy the OKE Terraform Module

## Prerequisites
* [Required Keys and OCIDs](https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm)
* [Required IAM policies](https://docs.cloud.oracle.com/iaas/Content/ContEng/Concepts/contengpolicyconfig.htm#PolicyPrerequisitesService)
* `git`, `ssh` client to run locally
* Terraform `>= 1.2.0` to run locally

## Provisioning from an OCI Resource Manager Stack

### Network
{{#include ./rms_network.md}}

### Cluster
{{#include ./rms_cluster.md}}

### Node Pool
{{#include ./rms_nodepool.md}}

### Virtual Node Pool
{{#include ./rms_virtualnodepool.md}}

### Instance
{{#include ./rms_instance.md}}

### Instance Pool
{{#include ./rms_instancepool.md}}

### Cluster Network
{{#include ./rms_clusternetwork.md}}
