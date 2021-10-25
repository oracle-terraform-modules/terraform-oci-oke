# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  ssh_private_key = var.ssh_private_key != "" ? var.ssh_private_key : var.ssh_private_key_path != "none" ? file(var.ssh_private_key_path) : null
  node_pools_size_list = [
    for node_pool in data.oci_containerengine_node_pools.all_node_pools.node_pools :
    node_pool.node_config_details[0].size
  ]

  # workaround for summing a list of numbers: https://github.com/hashicorp/terraform/issues/17239
  total_nodes = length(flatten([
    for nodes in local.node_pools_size_list : range(nodes)
  ]))

  service_account_cluster_role_binding_name = var.service_account_cluster_role_binding == "" ? "${var.service_account_name}-crb" : var.service_account_cluster_role_binding

  # 1. get a list of available images for this cluster
  # 2. filter by version
  # 3. if more than 1 image found for this version, pick the latest
  node_pool_image_ids = data.oci_containerengine_node_pool_option.node_pool_options.sources

  # determine if post provisioning operations are possible
  # requires:
  ## 1. bastion to be enabled and in a running state
  ## 2. operation to be enabled and instance_principal to be enabled

  post_provisioning_ops = var.create_bastion_host == true && var.bastion_state == "RUNNING" && var.create_operator == true && var.operator_state == "RUNNING" && var.enable_operator_instance_principal == true ? true : false

  dynamic_group_rule_this_cluster = (var.use_encryption == true) ? "ALL {resource.type = 'cluster', resource.id = '${var.cluster_id}'}" : "null"
}
