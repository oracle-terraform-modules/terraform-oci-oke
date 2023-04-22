# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "extensions" {
  source   = "./modules/extensions"
  count    = local.operator_enabled ? 1 : 0
  region   = var.region
  state_id = local.state_id

  # Cluster
  kubernetes_version  = var.kubernetes_version
  expected_node_count = local.worker_count_expected
  worker_pools        = one(module.workers[*].worker_pools)

  # Bastion/operator connection
  ssh_private_key = sensitive(local.ssh_private_key)
  bastion_host    = local.bastion_public_ip
  bastion_user    = var.bastion_user
  operator_host   = local.operator_private_ip
  operator_user   = var.operator_user

  # CNI
  vcn_cidrs = local.vcn_cidrs
  cni_type  = var.cni_type
  pods_cidr = var.pods_cidr

  # CNI: Calico
  calico_install           = var.calico_install
  calico_apiserver_install = var.calico_apiserver_install
  calico_mode              = var.calico_mode
  calico_mtu               = var.calico_mtu
  calico_staging_dir       = var.calico_staging_dir
  calico_typha_install     = var.calico_typha_install
  calico_typha_replicas    = var.calico_typha_replicas
  calico_url               = var.calico_url
  calico_version           = var.calico_version

  # CNI: Multus
  multus_install       = var.multus_install
  multus_namespace     = var.multus_namespace
  multus_daemonset_url = var.multus_daemonset_url
  multus_version       = var.multus_version

  # Metrics server
  metrics_server_install           = var.metrics_server_install
  metrics_server_namespace         = var.metrics_server_namespace
  metrics_server_helm_version      = var.metrics_server_helm_version
  metrics_server_helm_values       = var.metrics_server_helm_values
  metrics_server_helm_values_files = var.metrics_server_helm_values_files

  # Cluster autoscaler
  cluster_autoscaler_install           = var.cluster_autoscaler_install
  cluster_autoscaler_namespace         = var.cluster_autoscaler_namespace
  cluster_autoscaler_helm_version      = var.cluster_autoscaler_helm_version
  cluster_autoscaler_helm_values       = var.cluster_autoscaler_helm_values
  cluster_autoscaler_helm_values_files = var.cluster_autoscaler_helm_values_files

  # Gatekeeper
  gatekeeper_install           = var.gatekeeper_install
  gatekeeper_namespace         = var.gatekeeper_namespace
  gatekeeper_helm_version      = var.gatekeeper_helm_version
  gatekeeper_helm_values       = var.gatekeeper_helm_values
  gatekeeper_helm_values_files = var.gatekeeper_helm_values_files

  # Prometheus
  prometheus_install           = var.prometheus_install
  prometheus_reapply           = var.prometheus_reapply
  prometheus_namespace         = var.prometheus_namespace
  prometheus_helm_version      = var.prometheus_helm_version
  prometheus_helm_values       = var.prometheus_helm_values
  prometheus_helm_values_files = var.prometheus_helm_values_files
}
