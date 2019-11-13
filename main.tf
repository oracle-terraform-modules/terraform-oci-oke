# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 0.12.16"
}

module "base" {
  source = "./modules/base"

  # identity
  oci_base_identity = local.oci_base_identity

  # general oci parameters
  oci_base_general = local.oci_base_general

  # vcn parameters
  oci_base_vcn = local.oci_base_vcn

  # bastion parameters
  oci_base_bastion = local.oci_base_bastion
  
  # admin server parameters
  oci_base_admin = local.oci_base_admin

}

module "policies" {
  source = "./modules/policies"

  # identity
  oci_identity = local.oci_base_identity

  ssh_keys = local.oci_base_ssh_keys

  label_prefix = var.label_prefix

  admin = local.oke_admin

  dynamic_group = module.base.group_name

  oke_kms = local.oke_kms

  cluster_id = module.oke.cluster_id
}

module "auth" {
  source = "./modules/auth"

  # ocir parameters
  ocir = local.ocir
}

# additional networking for oke
module "network" {
  source = "./modules/okenetwork"

  # identity parameters
  compartment_id = var.compartment_id

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
  oke_admin = local.oke_admin

  # oke cluster parameters
  oke_cluster = local.oke_cluster

  # oke node pool parameters
  node_pools = local.node_pools

  # oke load balancer parameters
  lbs = local.lbs

  # ocir parameters
  oke_ocir = local.oke_ocir

  # helm parameters
  helm = local.helm

  # calico parameters
  calico = local.calico

  # metric server
  install_metricserver = var.install_metricserver
}
