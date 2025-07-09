# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  cluster_private_endpoint = (var.create_cluster ?
    coalesce(split(":", lookup(one(module.cluster[*].endpoints), "private_endpoint", ""))...) :
    (length(local.existing_cluster_endpoints) > 0 ?
      coalesce(split(":", lookup(local.existing_cluster_endpoints, "private_endpoint", ""))...) :
      null
    )
  )
}

module "extensions" {
  source     = "./modules/extensions"
  depends_on = [module.network]
  count      = alltrue([var.create_cluster, local.operator_enabled]) ? 1 : 0
  region     = var.region
  state_id   = local.state_id

  # Cluster
  kubernetes_version       = var.kubernetes_version
  expected_node_count      = local.worker_count_expected
  worker_pools             = one(module.workers[*].worker_pools)
  cluster_private_endpoint = local.cluster_private_endpoint

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

  # CNI: Cilium
  cilium_install           = var.cilium_install
  cilium_reapply           = var.cilium_reapply
  cilium_namespace         = var.cilium_namespace
  cilium_helm_version      = var.cilium_helm_version
  cilium_helm_values       = var.cilium_helm_values
  cilium_helm_values_files = var.cilium_helm_values_files


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
  expected_autoscale_worker_pools      = coalesce(one(module.workers[*].worker_pool_autoscale_expected), 0)

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

  # DCGM exporter
  dcgm_exporter_install           = var.dcgm_exporter_install
  dcgm_exporter_reapply           = var.dcgm_exporter_reapply
  dcgm_exporter_namespace         = var.dcgm_exporter_namespace
  dcgm_exporter_helm_version      = var.dcgm_exporter_helm_version
  dcgm_exporter_helm_values       = var.dcgm_exporter_helm_values
  dcgm_exporter_helm_values_files = var.dcgm_exporter_helm_values_files

  # SR-IOV device plugin
  sriov_device_plugin_install       = var.sriov_device_plugin_install
  sriov_device_plugin_namespace     = var.sriov_device_plugin_namespace
  sriov_device_plugin_daemonset_url = var.sriov_device_plugin_daemonset_url
  sriov_device_plugin_version       = var.sriov_device_plugin_version

  # SR-IOV CNI plugin
  sriov_cni_plugin_install       = var.sriov_cni_plugin_install
  sriov_cni_plugin_namespace     = var.sriov_cni_plugin_namespace
  sriov_cni_plugin_daemonset_url = var.sriov_cni_plugin_daemonset_url
  sriov_cni_plugin_version       = var.sriov_cni_plugin_version

  # SR-IOV CNI plugin
  rdma_cni_plugin_install       = var.rdma_cni_plugin_install
  rdma_cni_plugin_namespace     = var.rdma_cni_plugin_namespace
  rdma_cni_plugin_daemonset_url = var.rdma_cni_plugin_daemonset_url
  rdma_cni_plugin_version       = var.rdma_cni_plugin_version

  # Whereabouts IPAM plugin
  whereabouts_install       = var.whereabouts_install
  whereabouts_namespace     = var.whereabouts_namespace
  whereabouts_daemonset_url = var.whereabouts_daemonset_url
  whereabouts_version       = var.whereabouts_version

  # MPI operator
  mpi_operator_install        = var.mpi_operator_install
  mpi_operator_namespace      = var.mpi_operator_namespace
  mpi_operator_deployment_url = var.mpi_operator_deployment_url
  mpi_operator_version        = var.mpi_operator_version

  # Service Account
  create_service_account = var.create_service_account
  service_accounts       = var.service_accounts

  # Argocd
  argocd_install           = var.argocd_install
  argocd_namespace         = var.argocd_namespace
  argocd_helm_version      = var.argocd_helm_version
  argocd_helm_values       = var.argocd_helm_values
  argocd_helm_values_files = var.argocd_helm_values_files
}
