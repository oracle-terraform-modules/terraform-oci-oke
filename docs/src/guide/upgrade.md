# Upgrading

**TODO** Update content

This section documents how to upgrade the OKE cluster using this project. At a high level, upgrading the OKE cluster is fairly straightforward:

1. Upgrade the control plane nodes
2. Upgrade the worker nodes using either {uri-upgrade-oke}[in-place or out-of-place] approach

These steps must be performed in order.

```admonish notice
The out-of-place method is currently the **only** supported method of upgrading a cluster and worker nodes.
```

## Prerequisites

* Bastion host is created
* Operator host is created
* instance_principal is enabled on operator

## Upgrading the control plane nodes

Locate your `kubernetes_version` in your Terraform variable file and change:
```
kubernetes_version = "v1.22.5" 
```
to
```
kubernetes_version = "v1.23.4"
```

Run `terraform apply`. This will upgrade the control plane nodes. You can verify this in the OCI Console.

```admonish tip
If you have modified the default resources e.g. security lists, you will need to use a targeted apply:
```

```
terraform apply --target=module.oke.k8s_cluster
```

## Upgrading the worker nodes using the out-of-place method

### Add new node pools

Add a new node pool in your list of node pools e.g. change:
```
worker_pools = {
  np1 = ["VM.Standard.E2.2", 7, 50]
  np2 = ["VM.Standard2.8", 5, 50]
}
```
to
```
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
