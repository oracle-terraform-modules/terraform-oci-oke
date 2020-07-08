# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 0.12.24"
}

module "policies" {
  source = "./modules/policies"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # provider
  oci_provider = local.oci_base_provider

  ssh_keys = local.oci_base_ssh_keys

  operator = local.oke_operator

  dynamic_group = var.dynamicgroup_name

  oke_kms = local.oke_kms

  cluster_id = module.oke.cluster_id

  reuse = var.reuse
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

  # waf integration
  waf_enabled = var.waf_enabled

  reuse = var.reuse

#dns label
  worker_dnslabel = var.worker_dnslabel
  lb_dnslabel = var.lb_dnslabel
}

# cluster creation for oke
module "oke" {
  source = "./modules/oke"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # region parameters
  ad_names = sort(data.template_file.ad_names.*.rendered)
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

  # helm parameters
  helm = local.helm

  # calico parameters
  calico = local.calico

  # metric server
  metricserver_enabled = var.metricserver_enabled

  # service account
  service_account = local.service_account

  #check worker nodes are active
  check_node_active = var.check_node_active

  reuse = var.reuse

}
