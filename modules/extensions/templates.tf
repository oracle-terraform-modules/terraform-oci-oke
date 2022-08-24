# Copyright (c) 2017, 2022 Oracle Corporation and/or its affiliates.
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

  calico_env_template = templatefile("${path.module}/scripts/calico_env.sh",
    {
      mode              = var.calico_mode
      version           = var.calico_version
      cni_type          = var.cni_type
      mtu               = var.calico_mtu
      pod_cidr          = var.pods_cidr
      url               = var.calico_url
      apiserver_enabled = var.calico_apiserver_enabled
      typha_enabled     = var.typha_enabled || local.total_nodes > 50

      # Use provided value if set, otherwise use 1 replica for every 50 nodes with a min of 1 if enabled, and max of 20 replicas
      typha_replicas    = (var.typha_replicas > 0) ? var.typha_replicas : max(min(20, floor(local.total_nodes / 50)), var.typha_enabled ? 1 : 0)
    }
  )

  install_kubectx_template = templatefile("${path.module}/scripts/install_kubectx.template.sh", {
    version      = "0.9.4"
  })

  metric_server_template = templatefile("${path.module}/scripts/install_metricserver.template.sh",
    {
      enable_vpa  = var.enable_vpa
      vpa_version = var.vpa_version
    }
  )

  gatekeeper_template = templatefile("${path.module}/scripts/install_gatekeeper.template.sh",
    {
      enable_gatekeeper   = var.enable_gatekeeper
      gatekeeper_version = var.gatekeeper_version
    }
  )

  secret_template = templatefile("${path.module}/scripts/secret.template.sh",
    {
      compartment_id = var.compartment_id
      region         = var.region

      email_address     = var.email_address
      region_registry   = join("", [var.region, ".ocir.io"])
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
      cluster_name  = var.cluster_name
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
      dynamic_group_id   = var.use_cluster_encryption == true ? var.cluster_kms_dynamic_group_id : "null"
      dynamic_group_rule = local.dynamic_group_rule_this_cluster
      home_region        = data.oci_identity_regions.home_region.regions[0].name
    }
  )


}
