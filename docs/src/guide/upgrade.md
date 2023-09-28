# Upgrading

**TODO** Update content

This section documents how to upgrade the OKE cluster using this project. At a high level, upgrading the OKE cluster is fairly straightforward:

1. Upgrade the control plane nodes
2. Upgrade the worker nodes using either {uri-upgrade-oke}[in-place or out-of-place] approach

These steps must be performed in order.

<!---
```admonish notice
The out-of-place method is currently the **only** supported method of upgrading a cluster and worker nodes.
```
--->

## Prerequisites 

For in-place upgrade:
* Enhanced cluster

For out-of-place upgrade:
* Bastion host is created
* Operator host is created
* instance_principal is enabled on operator

## Upgrading the control plane nodes

Locate your `kubernetes_version` in your Terraform variable file and change:
```properties
kubernetes_version = "v1.22.5" 
```
to
```properties
kubernetes_version = "v1.23.4"
```

Run `terraform apply`. This will upgrade the control plane nodes. You can verify this in the OCI Console.

```admonish tip
If you have modified the default resources e.g. security lists, you will need to use a targeted apply:
```

```shell
terraform apply --target=module.oke.k8s_cluster
```

## Upgrading the worker nodes using the in-place method

In-place worker node upgrade is performed using the node_pool [node_cycle operation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengupgradingk8sworkernode_topic-Performing_an_InPlace_Worker_Node_Upgrade_by_Cycling_an_Existing_Node_Pool.htm).

Set `node_cycling_enabled` for the existing node_pools you want to upgrade and control the node replacement strategy using: `node_cycling_max_surge` and `node_cycling_max_unavailable`.

```properties
worker_pools = {
  cycled-node-pool = {
    description                  = "Cycling nodes in a node_pool.",
    size                         = 2,
    node_cycling_enabled         = true
    node_cycling_max_surge       = 1
    node_cycling_max_unavailable = 0
  }
}
```

By default, the node_pools are using the same Kubernetes version as the control plane (defined in the `kubernetes_version` variable).

**Note:** You can override each node_pool Kubernetes version via the `kubernetes_version` attribute in the `worker_pools` variable.

```properties
kubernetes_version = "v1.26.7" # control plane Kubernetes version (used by default for the node_pools).

worker_pools = {
  cycled-node-pool = {
    description                  = "Cycling nodes in a node_pool.",
    size                         = 2,
    kubernetes_version           = "v1.26.2" # override the default Kubernetes version
  }
}
```

### Worker node image compatibility

If the node_pool is configured to use a custom worker node image (`image_type = custom`), make sure that the worker ndoe image referenced in the `image_id` attribute of the `worker_pools` is compatible with the new `kubernetes_version`.


```properties
kubernetes_version = "v1.26.7" # control plane Kubernetes version (used by default for the node_pools).

worker_pools = {
  cycled-node-pool = {
    description                  = "Cycling nodes in a node_pool.",
    size                         = 2,
    image_type                   = "custom",
    image_id                     = "ocid1.image..."
  }
}
```

**Note:** A new `image_id`, compatible with the node_pool `kubernetes_version` is automatically configured when `image_type` is not configured for the node_pool or set to the values (`"oke"` or `"platform"`).

## Upgrading the worker nodes using the out-of-place method

### Add new node pools

Add a new node pool in your list of node pools e.g. change:
```properties
worker_pools = {
  np1 = ["VM.Standard.E2.2", 7, 50]
  np2 = ["VM.Standard2.8", 5, 50]
}
```
to
```properties
worker_pools = {
  np1 = ["VM.Standard.E2.2", 7, 50]
  np2 = ["VM.Standard2.8", 5, 50]
  np3 = ["VM.Standard.E2.2", 7, 50]
  np4 = ["VM.Standard2.8", 5, 50]
}
```

and run `terraform apply` again. (See note above about targeted apply). If you are using Kubernetes labels for your existing applications, you will need to ensure the new node pools also have the same labels. Refer to the `terraform.tfvars.example` file for the format to specify the labels.

When node pools 3 and 4 are created, they will be created with the newer cluster version of Kubernetes. Since you have already upgrade your cluster to `v1.23.4`, node pools 3 and 4 will be running Kubernetes v1.23.4.

### Drain older nodepools

Set `upgrade_nodepool=true`. This will instruct the OKE cluster that some node pools will be drained.

Provide the list of node pools to drain. This should usually be only the old node pools. You don't need to upgrade all the node pools at once.

```
worker_pools_to_drain = [ "np1", "np2"] 
```

Rerun `terraform apply` (see note above about targeted apply).

### Delete node pools with older Kubernetes version

When you are ready, you can now delete the old node pools by removing them from the list of node pools:
```
worker_pools = {
  np3 = ["VM.Standard.E2.2", 7, 50]
  np4 = ["VM.Standard2.8", 5, 50]
}
```

Rerun `terraform apply`. This completes the upgrade process. Now, set `upgrade_nodepool = false` to prevent draining from current nodes by mistake.
