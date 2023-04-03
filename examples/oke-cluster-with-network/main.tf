# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_region_subscriptions" "home" {
  tenancy_id = var.tenancy_ocid
  filter {
    name   = "is_home_region"
    values = [true]
  }
}

data "oci_secrets_secretbundle" "ssh_key" {
  secret_id = var.ssh_kms_secret_id

}

data "oci_secrets_secretbundle" "ocir" {
  count     = var.ocir_kms_vault_id == null ? 0 : 1
  secret_id = var.ocir_kms_secret_id
}

locals {
  bastion_allowed_cidrs       = compact(split(",", var.bastion_allowed_cidrs))
  bastion_nsg_ids             = compact(split(",", var.bastion_nsg_id))
  control_plane_allowed_cidrs = compact(split(",", var.control_plane_allowed_cidrs))
  control_plane_nsg_ids       = compact(split(",", var.control_plane_nsg_id))
  fss_nsg_ids                 = compact(split(",", var.fss_nsg_id))
  operator_nsg_ids            = compact(split(",", var.operator_nsg_id))
  pod_nsg_ids                 = compact(split(",", var.pod_nsg_id))
  worker_nsg_ids              = compact(split(",", var.worker_nsg_id))
  ssh_key_bundle_content      = sensitive(lookup(one(data.oci_secrets_secretbundle.ssh_key.secret_bundle_content), "content", null))
}

module "oke" {
  source         = "github.com/devoncrouse/terraform-oci-oke.git?ref=5.x-stack&depth=1"
  providers      = { oci.home = oci.home }
  tenancy_id     = var.tenancy_ocid
  compartment_id = var.compartment_ocid

  # General
  timezone      = var.timezone
  output_detail = var.output_detail

  # Identity
  create_iam_resources = true

  # Network
  create_vcn                  = var.create_vcn
  vcn_id                      = var.vcn_id
  vcn_cidrs                   = split(",", var.vcn_cidrs)
  vcn_create_internet_gateway = lower(var.vcn_create_internet_gateway)
  vcn_create_nat_gateway      = lower(var.vcn_create_nat_gateway)
  vcn_create_service_gateway  = lower(var.vcn_create_service_gateway)
  vcn_name                    = var.vcn_name
  vcn_dns_label               = var.vcn_dns_label
  assign_dns                  = var.assign_dns
  ig_route_table_id           = var.ig_route_table_id
  local_peering_gateways      = var.local_peering_gateways
  lockdown_default_seclist    = var.lockdown_default_seclist
  nat_gateway_public_ip_id    = var.nat_gateway_public_ip_id
  nat_route_table_id          = var.nat_route_table_id
  create_drg                  = var.create_drg
  drg_id                      = var.drg_id
  enable_waf                  = var.enable_waf
  subnets = {
    bastion  = { create = lower(var.bastion_subnet_create), newbits = var.bastion_subnet_newbits, id = var.bastion_subnet_id }
    operator = { create = lower(var.operator_subnet_create), newbits = var.operator_subnet_newbits, id = var.operator_subnet_id }
    cp       = { create = lower(var.control_plane_subnet_create), newbits = var.control_plane_subnet_newbits, id = var.control_plane_subnet_id }
    int_lb   = { create = lower(var.int_lb_subnet_create), newbits = var.int_lb_subnet_newbits, id = var.int_lb_subnet_id }
    pub_lb   = { create = lower(var.pub_lb_subnet_create), newbits = var.pub_lb_subnet_newbits, id = var.pub_lb_subnet_id }
    workers  = { create = lower(var.worker_subnet_create), newbits = var.worker_subnet_newbits, id = var.worker_subnet_id }
    pods     = { create = lower(var.pod_subnet_create), newbits = var.pod_subnet_newbits, id = var.pod_subnet_id }
    fss      = { create = lower(var.fss_subnet_create), newbits = var.fss_subnet_newbits, id = var.fss_subnet_id }
  }

  # Network Security
  create_nsgs                  = var.create_nsgs
  allow_node_port_access       = var.allow_node_port_access
  allow_pod_internet_access    = var.allow_pod_internet_access
  allow_rules_internal_lb      = var.allow_rules_internal_lb
  allow_rules_public_lb        = var.allow_rules_public_lb
  allow_worker_internet_access = var.allow_worker_internet_access
  allow_worker_ssh_access      = var.allow_worker_ssh_access
  bastion_allowed_cidrs        = local.bastion_allowed_cidrs
  bastion_nsg_ids              = local.bastion_nsg_ids
  control_plane_allowed_cidrs  = local.control_plane_allowed_cidrs
  control_plane_is_public      = var.control_plane_is_public
  control_plane_nsg_ids        = local.control_plane_nsg_ids
  fss_nsg_ids                  = local.fss_nsg_ids
  load_balancers               = lower(var.load_balancers)
  operator_nsg_ids             = local.operator_nsg_ids
  pod_nsg_ids                  = local.pod_nsg_ids
  worker_is_public             = var.worker_is_public
  worker_nsg_ids               = local.worker_nsg_ids

  # Bastion
  bastion_availability_domain = var.bastion_availability_domain
  bastion_image_id            = var.bastion_image_id
  bastion_image_os            = var.bastion_image_os
  bastion_image_os_version    = var.bastion_image_os_version
  bastion_image_type          = lower(var.bastion_image_type)
  bastion_is_public           = var.bastion_is_public
  bastion_public_ip           = var.bastion_public_ip
  bastion_shape               = var.bastion_shape
  bastion_upgrade             = var.bastion_upgrade
  bastion_user                = var.bastion_user
  create_bastion              = var.create_bastion

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
  cni_type                = lower(var.cni_type)
  create_cluster          = var.create_cluster
  cluster_type            = lower(var.cluster_type)
  kubernetes_version      = var.kubernetes_version
  pods_cidr               = var.pods_cidr
  preferred_load_balancer = lower(var.preferred_load_balancer)
  services_cidr           = var.services_cidr
  use_signed_images       = var.use_signed_images
  image_signing_keys      = var.image_signing_keys

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

  # Metrics server
  metrics_server_install      = var.metrics_server_install
  metrics_server_namespace    = var.metrics_server_namespace
  metrics_server_helm_version = var.metrics_server_helm_version
  # metrics_server_helm_values       = var.metrics_server_helm_values
  # metrics_server_helm_values_files = var.metrics_server_helm_values_files

  # Cluster autoscaler
  cluster_autoscaler_install      = var.cluster_autoscaler_install
  cluster_autoscaler_namespace    = var.cluster_autoscaler_namespace
  cluster_autoscaler_helm_version = var.cluster_autoscaler_helm_version
  # cluster_autoscaler_helm_values       = var.cluster_autoscaler_helm_values
  # cluster_autoscaler_helm_values_files = var.cluster_autoscaler_helm_values_files

  # Gatekeeper
  gatekeeper_install      = var.gatekeeper_install
  gatekeeper_namespace    = var.gatekeeper_namespace
  gatekeeper_helm_version = var.gatekeeper_helm_version
  # gatekeeper_helm_values       = var.gatekeeper_helm_values
  # gatekeeper_helm_values_files = var.gatekeeper_helm_values_files

  # Prometheus
  prometheus_install      = var.prometheus_install
  prometheus_namespace    = var.prometheus_namespace
  prometheus_helm_version = var.prometheus_helm_version
  # prometheus_helm_values       = var.prometheus_helm_values
  # prometheus_helm_values_files = var.prometheus_helm_values_files

  # Tags
  use_defined_tags = var.use_defined_tags
  tag_namespace    = var.tag_namespace

  freeform_tags = { # TODO Remaining tags in schema
    cluster           = lookup(var.cluster_tags, "freeformTags", {})
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = lookup(var.bastion_tags, "freeformTags", {})
    operator          = lookup(var.operator_tags, "freeformTags", {})
    vcn               = {}
  }

  defined_tags = { # TODO Remaining tags in schema
    cluster           = lookup(var.cluster_tags, "definedTags", {})
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = lookup(var.bastion_tags, "definedTags", {})
    operator          = lookup(var.operator_tags, "definedTags", {})
    vcn               = {}
  }
}
