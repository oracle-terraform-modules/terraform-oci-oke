# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

module "base" {
  source = "./modules/base"

  # identity 
  api_fingerprint      = "${var.api_fingerprint}"
  api_private_key_path = "${var.api_private_key_path}"
  compartment_name     = "${var.compartment_name}"
  compartment_ocid     = "${var.compartment_ocid}"
  tenancy_ocid         = "${var.tenancy_ocid}"
  user_ocid            = "${var.user_ocid}"
  ssh_private_key_path = "${var.ssh_private_key_path}"
  ssh_public_key_path  = "${var.ssh_public_key_path}"

  # general
  label_prefix = "${var.label_prefix}"
  region       = "${var.region}"

  # networking
  newbits                = "${var.newbits}"
  subnets                = "${var.subnets}"
  vcn_cidr               = "${var.vcn_cidr}"
  vcn_dns_name           = "${var.vcn_dns_name}"
  vcn_name               = "${var.vcn_name}"
  create_nat_gateway     = "${var.create_nat_gateway}"
  nat_gateway_name       = "${var.nat_gateway_name}"
  create_service_gateway = "${var.create_service_gateway}"
  service_gateway_name   = "${var.service_gateway_name}"

  # bastion
  bastion_shape                  = "${var.bastion_shape}"
  create_bastion                 = "${var.create_bastion}"
  enable_instance_principal      = "${var.enable_instance_principal}"
  image_ocid                     = "${var.image_ocid}"
  image_operating_system         = "${var.image_operating_system}"
  image_operating_system_version = "${var.image_operating_system_version}"

  # availability_domains
  availability_domains = "${var.availability_domains}"
}

module "auth" {
  source               = "./modules/auth"
  api_fingerprint      = "${var.api_fingerprint}"
  api_private_key_path = "${var.api_private_key_path}"
  compartment_ocid     = "${var.compartment_ocid}"
  create_auth_token    = "${var.create_auth_token}"
  home_region          = "${module.base.home_region}"
  tenancy_ocid         = "${var.tenancy_ocid}"
  user_ocid            = "${var.user_ocid}"
}

# additional networking for oke
module "network" {
  source = "./modules/okenetwork"

  # identity
  compartment_ocid = "${var.compartment_ocid}"
  tenancy_ocid     = "${var.tenancy_ocid}"

  # general
  ad_names     = "${module.base.ad_names}"
  label_prefix = "${var.label_prefix}"

  # networking
  ig_route_id  = "${module.base.ig_route_id}"
  nat_route_id = "${module.base.nat_route_id}"
  newbits      = "${var.newbits}"
  subnets      = "${var.subnets}"
  vcn_cidr     = "${var.vcn_cidr}"
  vcn_id       = "${module.base.vcn_id}"

  # availability domains
  availability_domains = "${var.availability_domains}"

  # oke
  worker_mode = "${var.worker_mode}"
}

# cluster creation for oke
module "oke" {
  source = "./modules/oke"

  # identity
  compartment_ocid = "${var.compartment_ocid}"
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"

  # ssh keys
  ssh_private_key_path = "${var.ssh_private_key_path}"
  ssh_public_key_path  = "${var.ssh_public_key_path}"

  # oci
  ad_names     = "${module.base.ad_names}"
  label_prefix = "${var.label_prefix}"
  region       = "${var.region}"

  # availability domains
  availability_domains = "${var.availability_domains}"

  # bastion
  bastion_public_ip         = "${module.base.bastion_public_ip}"
  create_bastion            = "${var.create_bastion}"
  enable_instance_principal = "${var.enable_instance_principal}"
  image_operating_system    = "${var.image_operating_system}"

  # networking
  vcn_id = "${module.base.vcn_id}"

  # oke
  cluster_kubernetes_version                              = "${var.kubernetes_version}"
  cluster_name                                            = "${var.cluster_name}"
  cluster_options_add_ons_is_kubernetes_dashboard_enabled = "${var.dashboard_enabled}"
  cluster_options_add_ons_is_tiller_enabled               = "${var.tiller_enabled}"
  cluster_options_kubernetes_network_config_pods_cidr     = "${var.pods_cidr}"
  cluster_options_kubernetes_network_config_services_cidr = "${var.services_cidr}"

  cluster_subnets = "${module.network.subnet_ids}"

  # node pools
  node_pools = "${var.node_pools}"

  node_pool_name_prefix         = "${var.node_pool_name_prefix}"
  node_pool_node_image_name     = "${var.node_pool_node_image_name}"
  node_pool_node_shape          = "${var.node_pool_node_shape}"
  node_pool_quantity_per_subnet = "${var.node_pool_quantity_per_subnet}"
  nodepool_topology             = "${var.nodepool_topology}"

  # ocir
  auth_token        = "${var.create_auth_token == true ? module.auth.ocirtoken : "none"}"
  create_auth_token = "${var.create_auth_token}"
  email_address     = "${var.email_address}"
  ocirtoken_id      = "${module.auth.ocirtoken_id}"
  ocir_urls         = "${var.ocir_urls}"
  tenancy_name      = "${var.tenancy_name}"
  username          = "${var.username}"

  # helm
  helm_version = "${var.helm_version}"
  install_helm = "${var.install_helm}"

  # calico
  calico_version = "${var.calico_version}"
  install_calico = "${var.install_calico}" 
}