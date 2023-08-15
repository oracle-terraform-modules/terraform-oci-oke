# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_secrets_secretbundle" "ocir" {
  count     = var.ocir_kms_vault_id == null ? 0 : 1
  secret_id = var.ocir_kms_secret_id
}

module "oke" {
  source         = "github.com/oracle-terraform-modules/terraform-oci-oke.git?ref=5.x&depth=1"
  providers      = { oci.home = oci.home }
  tenancy_id     = var.tenancy_ocid
  compartment_id = var.compartment_ocid

  # General
  timezone      = var.timezone
  output_detail = var.output_detail

  # Identity
  create_iam_resources = true

  # Network
  create_vcn                  = false
  vcn_id                      = var.vcn_id
  vcn_create_internet_gateway = "never"
  vcn_create_nat_gateway      = "never"
  vcn_create_service_gateway  = "never"
  assign_dns                  = var.assign_dns
  ig_route_table_id           = var.ig_route_table_id
  subnets = {
    operator = { create = "never", id = var.operator_subnet_id }
    cp       = { create = "never", id = var.control_plane_subnet_id }
    int_lb   = { create = "never", id = var.int_lb_subnet_id }
    pub_lb   = { create = "never", id = var.pub_lb_subnet_id }
  }

  nsgs = {
    operator = { create = "never", id = var.operator_nsg_id }
    cp       = { create = "never", id = var.control_plane_nsg_id }
  }

  # Network Security
  control_plane_is_public = var.control_plane_is_public
  load_balancers          = lower(var.load_balancers)
  create_bastion          = false
  bastion_public_ip       = var.bastion_public_ip

  # Operator
  create_operator                = var.create_operator
  operator_availability_domain   = var.operator_availability_domain
  operator_cloud_init            = var.operator_cloud_init
  operator_image_id              = var.operator_image_id
  operator_image_os              = var.operator_image_os
  operator_image_os_version      = var.operator_image_os_version
  operator_install_helm          = var.operator_install_helm
  operator_install_k9s           = var.operator_install_k9s
  operator_install_kubectx       = var.operator_install_kubectx
  operator_private_ip            = var.operator_private_ip
  operator_pv_transit_encryption = var.operator_pv_transit_encryption
  operator_shape                 = var.operator_shape
  operator_upgrade               = var.operator_upgrade
  operator_user                  = var.operator_user
  operator_volume_kms_key_id     = var.operator_volume_kms_key_id

  # SSH
  ssh_public_key  = local.ssh_public_key
  ssh_private_key = sensitive(local.ssh_key_bundle_content)

  # Cluster
  cluster_kms_key_id      = var.cluster_kms_key_id
  cluster_name            = var.cluster_name
  cluster_type            = lower(var.cluster_type)
  cni_type                = lower(var.cni_type)
  create_cluster          = true
  image_signing_keys      = var.image_signing_keys
  kubernetes_version      = var.kubernetes_version
  pods_cidr               = var.pods_cidr
  preferred_load_balancer = lower(var.preferred_load_balancer)
  services_cidr           = var.services_cidr
  use_signed_images       = var.use_signed_images

  # CNI: Cilium
  cilium_install           = var.cilium_install
  cilium_reapply           = var.cilium_reapply
  cilium_namespace         = var.cilium_namespace
  cilium_helm_version      = var.cilium_helm_version
  cilium_helm_values       = var.cilium_helm_values
  cilium_helm_values_files = var.cilium_helm_values_files

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

  # DCGM exporter
  dcgm_exporter_install      = var.dcgm_exporter_install
  dcgm_exporter_reapply      = var.dcgm_exporter_reapply
  dcgm_exporter_namespace    = var.dcgm_exporter_namespace
  dcgm_exporter_helm_version = var.dcgm_exporter_helm_version

  # Multus
  multus_install       = var.multus_install
  multus_namespace     = var.multus_namespace
  multus_daemonset_url = var.multus_daemonset_url
  multus_version       = var.multus_version

  # SR-IOV device plugin
  sriov_device_plugin_install       = var.sriov_device_plugin_install
  sriov_device_plugin_namespace     = var.sriov_device_plugin_namespace
  sriov_device_plugin_daemonset_url = var.sriov_device_plugin_daemonset_url
  sriov_device_plugin_version       = var.sriov_device_plugin_version

  # Whereabouts
  whereabouts_install       = var.whereabouts_install
  whereabouts_namespace     = var.whereabouts_namespace
  whereabouts_daemonset_url = var.whereabouts_daemonset_url
  whereabouts_version       = var.whereabouts_version

  # MPI operator
  mpi_operator_install        = var.mpi_operator_install
  mpi_operator_namespace      = var.mpi_operator_namespace
  mpi_operator_deployment_url = var.mpi_operator_deployment_url
  mpi_operator_version        = var.mpi_operator_version

  # Tags
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace

  freeform_tags = { # TODO Remaining tags in schema
    cluster           = lookup(var.cluster_tags, "freeformTags", {})
    persistent_volume = {}
    service_lb        = {}
    operator          = lookup(var.operator_tags, "freeformTags", {})
  }

  defined_tags = { # TODO Remaining tags in schema
    cluster           = lookup(var.cluster_tags, "definedTags", {})
    persistent_volume = {}
    service_lb        = {}
    operator          = lookup(var.operator_tags, "definedTags", {})
  }
}
