# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "base" {
  source  = "oracle-terraform-modules/base/oci"
  version = "2.0.0"

  # general oci parameters
  oci_base_general = local.oci_base_general

  # identity
  oci_base_provider = local.oci_base_provider

  # vcn parameters
  oci_base_vcn = local.oci_base_vcn

  # bastion parameters
  oci_base_bastion = local.oci_base_bastion

  # operator server parameters
  oci_base_operator = local.oci_base_operator

}

module "policies" {
  source = "./modules/policies"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # provider
  api_fingerprint      = var.api_fingerprint
  api_private_key_path = var.api_private_key_path
  region               = var.region
  tenancy_id           = var.tenancy_id
  user_id              = var.user_id

  ssh_keys = local.oci_base_ssh_keys

  operator = local.oke_operator

  dynamic_group = module.base.group_name

  oke_kms = local.oke_kms

  cluster_id = module.oke.cluster_id
}

# additional networking for oke
module "network" {
  source = "./modules/okenetwork"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # oke networking parameters
  oke_network_vcn = local.oke_network_vcn

  # oke worker network parameters
  oke_network_worker = local.oke_network_worker

  # oke load balancer network parameters
  lb_subnet_type = var.lb_subnet_type

  # oke load balancer ports
  public_lb_ports = var.public_lb_ports

  # waf integration
  waf_enabled = var.waf_enabled

}

# cluster creation for oke
module "oke" {
  source = "./modules/oke"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # region parameters
  ad_names = module.base.ad_names
  region   = var.region

  # ssh keys
  oke_ssh_keys = local.oci_base_ssh_keys

  # bastion details
  oke_operator = local.oke_operator

  # oke cluster parameters
  oke_cluster = local.oke_cluster

  # oke node pool parameters
  node_pools = local.node_pools

  # oke load balancer parameters
  lbs = local.lbs

  # ocir parameters
  oke_ocir = local.oke_ocir

  # calico parameters
  calico_enabled = var.calico_enabled

  # metric server
  metricserver_enabled = var.metricserver_enabled
  vpa                  = var.vpa

  # service account
  service_account = local.service_account

  #check worker nodes are active
  check_node_active = var.check_node_active

  nodepool_drain = var.nodepool_drain

  nodepool_upgrade_method = var.nodepool_upgrade_method

  node_pools_to_drain = var.node_pools_to_drain

}
