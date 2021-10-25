# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # scripting templates

  check_active_worker_template = templatefile("${path.module}/scripts/check_worker_active.template.sh",
    {
      check_node_active = var.check_node_active
      total_nodes       = local.total_nodes
    }
  )

  create_service_account_template = templatefile("${path.module}/scripts/create_service_account.template.sh",
    {
      service_account_name                 = var.service_account_name
      service_account_namespace            = var.service_account_namespace
      service_account_cluster_role_binding = local.service_account_cluster_role_binding_name
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

  generate_kubeconfig_template = templatefile("${path.module}/scripts/generate_kubeconfig.template.sh",
    {
      cluster-id = var.cluster_id
      region     = var.region
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

  install_helm_template = templatefile("${path.module}/scripts/install_helm.template.sh", {})

  install_kubectl_template = templatefile("${path.module}/scripts/install_kubectl.template.sh",
    {
      ol = var.operator_os_version
    }
  )

  metric_server_template = templatefile("${path.module}/scripts/install_metricserver.template.sh",
    {
      enable_vpa  = var.enable_vpa
      vpa_version = var.vpa_version
    }
  )

  secret_template = templatefile("${path.module}/scripts/secret.sh",
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

  set_credentials_template = templatefile("${path.module}/scripts/kubeconfig_set_credentials.template.sh",
    {
      cluster-id    = var.cluster_id
      cluster-id-11 = substr(var.cluster_id, (length(var.cluster_id) - 11), length(var.cluster_id))
      region        = var.region
    }
  )

  token_helper_template = templatefile("${path.module}/scripts/token_helper.template.sh",
    {
      cluster-id = var.cluster_id
      region     = var.region
    }
  )

  update_dynamic_group_template = templatefile("${path.module}/scripts/update_dynamic_group.template.sh",
    {
      dynamic_group_id   = var.use_encryption == true ? var.kms_dynamic_group_id : "null"
      dynamic_group_rule = local.dynamic_group_rule_this_cluster
      home_region        = data.oci_identity_regions.home_region.regions[0].name
    }
  )


}
