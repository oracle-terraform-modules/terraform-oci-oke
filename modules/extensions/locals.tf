# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

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

  # scripting templates
  update_dynamic_group_template = templatefile("${path.module}/scripts/update_dynamic_group.template.sh",
    {
      dynamic_group_id   = var.use_encryption == true ? var.kms_dynamic_group_id : "null"
      dynamic_group_rule = local.dynamic_group_rule_this_cluster
      home_region        = data.oci_identity_regions.home_region.regions[0].name
    }
  )

  check_active_worker_template = templatefile("${path.module}/scripts/check_worker_active.template.sh",
    {
      check_node_active = var.check_node_active
      total_nodes       = local.total_nodes
    }
  )

  install_calico_template = templatefile("${path.module}/scripts/install_calico.template.sh",
    {
      calico_version     = var.calico_version
      number_of_nodes    = local.total_nodes
      pod_cidr           = var.pods_cidr
      number_of_replicas = min(20, max((local.total_nodes) / 200, 3))
    }
  )

  drain_template = templatefile("${path.module}/scripts/drain.template.sh", {})

  drain_list_template = templatefile("${path.module}/scripts/drainlist.py",
    {
      cluster_id     = var.cluster_id
      compartment_id = var.compartment_id
      region         = var.region
      pools_to_drain = var.label_prefix == "none" ? trim(join(",", formatlist("'%s'", var.node_pools_to_drain)), "'") : trim(join(",", formatlist("'%s-%s'", var.label_prefix, var.node_pools_to_drain)), "'")
    }
  )

  install_kubectl_template = templatefile("${path.module}/scripts/install_kubectl.template.sh",
    {
      ol = var.operator_os_version
    }
  )

  install_helm_template = templatefile("${path.module}/scripts/install_helm.template.sh", {})

  metric_server_template = templatefile("${path.module}/scripts/install_metricserver.template.sh",
    {
      enable_vpa  = var.enable_vpa
      vpa_version = var.vpa_version
    }
  )

  secret_template = templatefile("${path.module}/scripts/secret.py",
    {
      compartment_id = var.compartment_id
      region         = var.region

      email_address     = var.email_address
      region_registry   = var.ocir_urls[var.region]
      secret_id         = var.secret_id
      secret_name       = var.secret_name
      secret_namespace  = var.secret_namespace
      tenancy_namespace = data.oci_objectstorage_namespace.object_storage_namespace.namespace
      username          = var.username
    }
  )

  create_service_account_template = templatefile("${path.module}/scripts/create_service_account.template.sh",
    {
      service_account_name                 = var.service_account_name
      service_account_namespace            = var.service_account_namespace
      service_account_cluster_role_binding = local.service_account_cluster_role_binding_name
    }
  )
}
