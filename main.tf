# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

module "base" {
  source = "./modules/base"

  # identity 
  compartment_ocid          = "${var.compartment_ocid}"
  compartment_name          = "${var.compartment_name}"
  tenancy_ocid              = "${var.tenancy_ocid}"
  user_ocid                 = "${var.user_ocid}"
  api_fingerprint           = "${var.api_fingerprint}"
  api_private_key_path      = "${var.api_private_key_path}"
  ssh_private_key_path      = "${var.ssh_private_key_path}"
  ssh_public_key_path       = "${var.ssh_public_key_path}"
  enable_instance_principal = "${var.enable_instance_principal}"
  label_prefix              = "${var.label_prefix}"

  # networking
  vcn_name     = "${var.vcn_name}"
  region       = "${var.region}"
  vcn_dns_name = "${var.vcn_dns_name}"
  label_prefix = "${var.label_prefix}"
  vcn_cidr     = "${var.vcn_cidr}"
  newbits      = "${var.newbits}"
  subnets      = "${var.subnets}"

  # compute
  preferred_bastion_image = "${var.preferred_bastion_image}"
  imageocids              = "${var.imageocids}"
  bastion_shape           = "${var.bastion_shape}"

  # availability_domains
  availability_domains = "${var.availability_domains}"

  create_nat_gateway = "${var.create_nat_gateway}"
  nat_gateway_name   = "${var.nat_gateway_name}"

  create_service_gateway = "${var.create_service_gateway}"
  service_gateway_name   = "${var.service_gateway_name}"
}

module "auth" {
  source               = "./modules/auth"
  compartment_ocid     = "${var.compartment_ocid}"
  tenancy_ocid         = "${var.tenancy_ocid}"
  user_ocid            = "${var.user_ocid}"
  api_fingerprint      = "${var.api_fingerprint}"
  api_private_key_path = "${var.api_private_key_path}"
  home_region          = "${module.base.home_region}"
  create_auth_token    = "${var.create_auth_token}"
}

# additional networking for oke
module "network" {
  source               = "./modules/okenetwork"
  compartment_ocid     = "${var.compartment_ocid}"
  tenancy_ocid         = "${var.tenancy_ocid}"
  label_prefix         = "${var.label_prefix}"
  vcn_id               = "${module.base.vcn_id}"
  ig_route_id          = "${module.base.ig_route_id}"
  subnets              = "${var.subnets}"
  vcn_cidr             = "${var.vcn_cidr}"
  newbits              = "${var.newbits}"
  ad_names             = "${module.base.ad_names}"
  availability_domains = "${var.availability_domains}"
  worker_mode          = "${var.worker_mode}"
  nat_route_id         = "${module.base.nat_route_id}"
}

# cluster creation for oke
module "oke" {
  source                  = "./modules/oke"
  compartment_ocid        = "${var.compartment_ocid}"
  tenancy_ocid            = "${var.tenancy_ocid}"
  user_ocid               = "${var.user_ocid}"
  label_prefix            = "${var.label_prefix}"
  preferred_bastion_image = "${var.preferred_bastion_image}"
  availability_domains    = "${var.availability_domains}"
  ad_names                = "${module.base.ad_names}"
  bastion_public_ips      = "${module.base.bastion_public_ips}"
  vcn_id                  = "${module.base.vcn_id}"
  ssh_private_key_path    = "${var.ssh_private_key_path}"
  ssh_public_key_path     = "${var.ssh_public_key_path}"
  region                  = "${var.region}"

  # oke cluster
  cluster_subnets                                         = "${module.network.subnet_ids}"
  cluster_kubernetes_version                              = "${var.kubernetes_version}"
  cluster_name                                            = "${var.cluster_name}"
  cluster_options_add_ons_is_kubernetes_dashboard_enabled = "${var.dashboard_enabled}"
  cluster_options_add_ons_is_tiller_enabled               = "${var.tiller_enabled}"
  cluster_options_kubernetes_network_config_pods_cidr     = "${var.pods_cidr}"
  cluster_options_kubernetes_network_config_services_cidr = "${var.services_cidr}"

  # node pools
  node_pool_name_prefix         = "${var.node_pool_name_prefix}"
  node_pool_node_image_name     = "${var.node_pool_node_image_name}"
  node_pool_node_shape          = "${var.node_pool_node_shape}"
  node_pool_quantity_per_subnet = "${var.node_pool_quantity_per_subnet}"
  node_pools                    = "${var.node_pools}"
  nodepool_topology             = "${var.nodepool_topology}"

  # ocir
  ocir_urls         = "${var.ocir_urls}"
  tenancy_name      = "${var.tenancy_name}"
  username          = "${var.username}"
  email_address     = "${var.email_address}"
  create_auth_token = "${var.create_auth_token}"
  auth_token        = "${var.create_auth_token == "true" ? module.auth.ocirtoken : "none"}"
  ocirtoken_id      = "${module.auth.ocirtoken_id}"

  # helm
  install_helm = "${var.install_helm}"
  helm_version = "${var.helm_version}"

  # ksonnet
  install_ksonnet = "${var.install_ksonnet}"
  ksonnet_version = "${var.ksonnet_version}"

  # calico
  install_calico = "${var.install_calico}"
  calico_version = "${var.calico_version}"
}
