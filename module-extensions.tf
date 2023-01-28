# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "extensions" {
  count          = local.operator_enabled ? 1 : 0
  source         = "./modules/extensions"
  compartment_id = local.compartment_id
  region         = var.region

  ssh_private_key     = local.ssh_private_key
  bastion_public_ip   = local.bastion_public_ip
  bastion_user        = var.bastion_user
  operator_private_ip = local.operator_private_ip
  operator_user       = var.operator_user

  # OKE cluster
  cluster_id = one(module.cluster[*].cluster_id)
  pods_cidr  = var.pods_cidr

  # OCIR
  email_address    = var.email_address
  secret_id        = var.secret_id
  secret_name      = var.secret_name
  secret_namespace = var.secret_namespace
  username         = var.username

  # Calico
  enable_calico            = var.enable_calico
  calico_version           = var.calico_version
  calico_mode              = var.calico_mode
  cni_type                 = var.cni_type
  calico_mtu               = var.calico_mtu
  calico_url               = var.calico_url
  calico_apiserver_enabled = var.calico_apiserver_enabled
  calico_staging_dir       = var.calico_staging_dir
  typha_enabled            = var.typha_enabled
  typha_replicas           = var.typha_replicas

  # Metric server
  enable_metric_server = var.enable_metric_server
  enable_vpa           = var.enable_vpa
  vpa_version          = var.vpa_version

  # Gatekeeper
  enable_gatekeeper  = var.enable_gatekeeper
  gatekeeper_version = var.gatekeeper_version

  # Service account
  create_service_account               = var.create_service_account
  service_account_name                 = var.service_account_name
  service_account_namespace            = var.service_account_namespace
  service_account_cluster_role_binding = var.service_account_cluster_role_binding

  # Worker node readiness
  check_node_active   = var.check_node_active
  expected_node_count = local.worker_count_expected

  # OKE upgrade
  upgrade_nodepool    = var.upgrade_nodepool
  node_pools_to_drain = var.node_pools_to_drain

  # Cluster autoscaler
  deploy_cluster_autoscaler = var.deploy_cluster_autoscaler
  autoscaling_groups        = local.autoscaling_groups

  providers = {
    oci.home = oci.home
  }
}
