# Operator: Identity

## `instance_principal`

[Instance_principal](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm) is an IAM service feature that enables instances to be authorized actors (or principals) to perform actions on service resources. Each compute instance has its own identity, and it authenticates using the certificates that are added to it. These certificates are automatically created, assigned to instances and rotated, preventing the need for you to distribute credentials to your hosts and rotate them.

[Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm) group OCI instances as principal actors, similar to user groups.  IAM policies can then
be created to allow instances in these groups to make calls against OCI infrastructure services.  For example, on the operator host,
this permits kubectl to access the OKE cluster.

Any user who has access to the instance (who can SSH to the instance), automatically inherits the privileges granted to the instance. Before you enable this feature, ensure that you know who can access it, and that they should be authorized with the permissions you are granting to the instance.

By default, this feature is **disabled**. However, it is **required** at the time of cluster creation *_if_* you wish to enable [KMS Integration]() or [Extensions](./extensions.md).

When you enable this feature, by default, the operator host will have privileges to all resources in the compartment. If you are enabling it for [KMS Integration](), the operator host will also have rights to create policies in the root tenancy. 

## Enabling `instance_principal` for the operator instance

`instance_principal` for the operator instance can be enabled or disabled at any time without impact on the operator or the cluster.

To enable this feature, specify the following to create of the necessary IAM policies,
[Dynamic Groups](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm), and [Matching Rules](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm):

```properties
create_iam_resources = true
create_iam_operator_policy = "always"
```

To disable this feature, specify:

```properties
create_iam_operator_policy = "never"
```
