# Resources

## Identity Access Management (IAM)
<!-- BEGIN_TF_IAM -->

* [oci_identity_dynamic_group.autoscaling](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group)
* [oci_identity_dynamic_group.cluster](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group)
* [oci_identity_dynamic_group.operator](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group)
* [oci_identity_dynamic_group.workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_dynamic_group)
* [oci_identity_policy.cluster](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy)
* [oci_identity_tag.oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_tag)
* [oci_identity_tag_namespace.oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_tag_namespace)
* [time_sleep.await_iam_resources](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)

<!-- END_TF_IAM -->

## Network
<!-- BEGIN_TF_NETWORK -->

* [null_resource.validate_subnets](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)
* [oci_core_drg.oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg)
* [oci_core_drg_attachment.extra](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg_attachment)
* [oci_core_drg_attachment.oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg_attachment)
* [oci_core_network_security_group.bastion](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group.cp](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group.fss](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group.int_lb](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group.operator](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group.pods](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group.pub_lb](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group.workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group)
* [oci_core_network_security_group_security_rule.oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group_security_rule)
* [oci_core_security_list.oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list)
* [oci_core_subnet.oke](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet)

<!-- END_TF_NETWORK -->

## Bastion
<!-- BEGIN_TF_BASTION -->

* [null_resource.await_cloudinit](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)
* [oci_core_instance.bastion](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

<!-- END_TF_BASTION -->

## Cluster
<!-- BEGIN_TF_CLUSTER -->

* [oci_containerengine_cluster.k8s_cluster](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster)

<!-- END_TF_CLUSTER -->

## Workers
<!-- BEGIN_TF_WORKERS -->

* [oci_containerengine_node_pool.tfscaled_workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool)
* [oci_containerengine_virtual_node_pool.workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_virtual_node_pool)
* [oci_core_cluster_network.workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_cluster_network)
* [oci_core_instance.workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)
* [oci_core_instance_configuration.workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_configuration)
* [oci_core_instance_pool.workers](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance_pool)

<!-- END_TF_WORKERS -->

## Operator
<!-- BEGIN_TF_OPERATOR -->

* [null_resource.await_cloudinit](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)
* [null_resource.operator_changed](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource)
* [oci_core_instance.operator](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance)

<!-- END_TF_OPERATOR -->
