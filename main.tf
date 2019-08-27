# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

module "base" {
  source = "./modules/base"

  # identity
  oci_base_identity = local.oci_base_identity

  # ssh keys
  oci_base_ssh_keys = local.oci_base_ssh_keys

  # general oci parameters
  oci_base_general = local.oci_base_general

  # vcn parameters
  oci_base_vcn = local.oci_base_vcn

  # bastion parameters
  oci_base_bastion = local.oci_base_bastion
}

module "auth" {
  source               = "./modules/auth"
  api_fingerprint      = var.api_fingerprint
  api_private_key_path = var.api_private_key_path
  compartment_ocid     = var.compartment_ocid
  create_auth_token    = var.create_auth_token
  home_region          = module.base.home_region
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
}

# additional networking for oke
module "network" {
  source = "./modules/okenetwork"

  # identity parameters
  compartment_ocid = var.compartment_ocid

  # general parameters
  oke_general = local.oke_general

  # oke networking parameters
  oke_network_vcn = local.oke_network_vcn

  # oke worker network parameters
  oke_network_worker = local.oke_network_worker

  # oke load balancer network parameters
  lb_subnet_type = var.lb_subnet_type
}

# cluster creation for oke
module "oke" {
  source = "./modules/oke"

  # identity
  oke_identity = local.oke_identity

  # ssh keys
  oke_ssh_keys = local.oci_base_ssh_keys

  # oci parameters
  oke_general = local.oke_general

  # bastion details
  oke_bastion = local.oke_bastion

  # oke cluster parameters
  oke_cluster = local.oke_cluster

  # oke node pool parameters
  node_pools = local.node_pools

  # oke load balancer parameters
  lbs = local.lbs

  # ocir parameters
  ocir = local.ocir

  # helm parameters
  helm = local.helm

  # calico parameters
  calico = local.calico

  # metric server
  install_metricserver = var.install_metricserver
}
