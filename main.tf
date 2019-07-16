# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

module "base" {
  source = "./modules/base"

  # identity  
  oci_base_identity = local.oci_base_identity

  # ssh
  oci_base_ssh_keys = local.oci_base_ssh_keys

  # general
  oci_base_general = local.oci_base_general

  # vcn
  oci_base_vcn = local.oci_base_vcn

  # bastion
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

  # identity
  compartment_ocid = var.compartment_ocid
  tenancy_ocid     = var.tenancy_ocid

  # general
  ad_names     = module.base.ad_names
  label_prefix = var.label_prefix

  # networking
  ig_route_id                = module.base.ig_route_id
  is_service_gateway_enabled = var.create_service_gateway
  nat_route_id               = module.base.nat_route_id
  newbits                    = var.newbits
  region                     = var.region
  subnets                    = var.subnets
  vcn_cidr                   = var.vcn_cidr
  vcn_id                     = module.base.vcn_id

  # availability domains
  availability_domains = var.availability_domains

  # oke
  allow_node_port_access  = var.allow_node_port_access
  allow_worker_ssh_access = var.allow_worker_ssh_access
  worker_mode             = var.worker_mode

  # load balancers
  load_balancer_subnet_type       = var.load_balancer_subnet_type
  preferred_load_balancer_subnets = var.preferred_load_balancer_subnets
}

# cluster creation for oke
module "oke" {
  source = "./modules/oke"

  # identity
  compartment_ocid = var.compartment_ocid
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid

  # ssh keys
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path

  # oci
  ad_names     = module.base.ad_names
  label_prefix = var.label_prefix
  region       = var.region

  # availability domains
  availability_domains = var.availability_domains

  # bastion
  bastion_public_ip         = module.base.bastion_public_ip
  create_bastion            = var.create_bastion
  enable_instance_principal = var.enable_instance_principal
  image_operating_system    = var.image_operating_system

  # networking
  vcn_id = module.base.vcn_id

  # oke
  cluster_kubernetes_version                              = var.kubernetes_version
  cluster_name                                            = var.cluster_name
  cluster_options_add_ons_is_kubernetes_dashboard_enabled = var.dashboard_enabled
  cluster_options_add_ons_is_tiller_enabled               = var.tiller_enabled
  cluster_options_kubernetes_network_config_pods_cidr     = var.pods_cidr
  cluster_options_kubernetes_network_config_services_cidr = var.services_cidr
  cluster_subnets                                         = module.network.subnet_ids

  # node pools
  node_pools = var.node_pools

  node_pool_name_prefix                    = var.node_pool_name_prefix
  node_pool_image_id                       = var.node_pool_image_id
  node_pool_image_operating_system         = var.node_pool_image_operating_system
  node_pool_image_operating_system_version = var.node_pool_image_operating_system_version
  node_pool_node_shape                     = var.node_pool_node_shape
  node_pool_quantity_per_subnet            = var.node_pool_quantity_per_subnet
  nodepool_topology                        = var.nodepool_topology

  # load balancers
  preferred_lb_ads                = var.preferred_lb_ads
  preferred_load_balancer_subnets = var.preferred_load_balancer_subnets

  # ocir
  auth_token        = module.auth.ocirtoken
  create_auth_token = var.create_auth_token
  email_address     = var.email_address
  ocirtoken_id      = module.auth.ocirtoken_id
  ocir_urls         = var.ocir_urls
  tenancy_name      = var.tenancy_name
  username          = var.username

  # helm
  add_incubator_repo = var.add_incubator_repo
  add_jetstack_repo  = var.add_incubator_repo
  helm_version       = var.helm_version
  install_helm       = var.install_helm

  # calico
  calico_version = var.calico_version
  install_calico = var.install_calico
}
