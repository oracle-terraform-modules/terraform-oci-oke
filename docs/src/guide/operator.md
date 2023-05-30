# Operator

The operator instance provides an optional environment within the VCN from which the OKE cluster can be managed.

## General

The operator host parameters concern:
1. whether you want to enable the operator
1. from where you can access the operator
1. the different parameters about the operator host e.g. shape, image id etc.

## SSH

Command usage for `ssh` through the created bastion to the operator host is included in the module's output:
```
$ terraform output
cluster = {
  "bastion_public_ip" = "138.0.0.1"
  "ssh_to_operator" = "ssh -J opc@138.0.0.1 opc@10.0.0.16"
  ...
}

$ ssh -J opc@138.0.0.1 opc@10.0.0.16 kubectl get nodes
NAME          STATUS   ROLES    AGE     VERSION
10.1.48.175   Ready    node     7d10h   v1.25.6
10.1.50.102   Ready    node     3h12m   v1.25.6
10.1.52.76    Ready    node     7d10h   v1.25.6
10.1.54.237   Ready    node     5h41m   v1.25.6
10.1.58.74    Ready    node     5h22m   v1.25.4
10.1.62.90    Ready    node     3h12m   v1.25.6
```

## Identity

### Authorizing the operator `instance_principal`

[Instance_principal](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm) is an IAM service feature that enables instances to be authorized actors (or principals) to perform actions on service resources. Each compute instance has its own identity, and it authenticates using the certificates that are added to it. These certificates are automatically created, assigned to instances and rotated, preventing the need for you to distribute credentials to your hosts and rotate them.

Any user who has access to the instance (who can SSH to the instance), automatically inherits the privileges granted to the instance. Before you enable this feature, ensure that you know who can access it, and that they should be authorized with the permissions you are granting to the instance.

By default, this feature is **disabled**. However, it is **required** at the time of cluster creation *_if_* you wish to enable [KMS Integration]() or [Extensions](./extensions.md).

When you enable this feature, by default, the operator host will have privileges to all resources in the compartment. If you are enabling it for [KMS Integration](), the operator host will also have rights to create policies in the root tenancy. 

You can also turn on and off the feature at any time without impact on the operator or the cluster.
