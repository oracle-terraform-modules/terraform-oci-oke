# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # used by cluster
  lb_subnet = var.lbs.preferred_lb_subnets == "public" ? "pub_lb" : "int_lb"

  node_pools_size_list = [
    for node_pool in data.oci_containerengine_node_pools.all_node_pools.node_pools :
    node_pool.node_config_details[0].size
  ]

  # workaround for summing a list of numbers: https://github.com/hashicorp/terraform/issues/17239
  total_nodes = length(flatten([
    for nodes in local.node_pools_size_list : range(nodes)
  ]))

  service_account_cluster_role_binding_name = var.service_account.service_account_cluster_role_binding == "" ? "${var.service_account.service_account_name}-crb" : var.service_account.service_account_cluster_role_binding

}
