# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.0.0-RC1"

  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # gateways
  create_drg                   = var.create_drg
  drg_display_name             = var.drg_display_name
  internet_gateway_enabled     = true
  lockdown_default_seclist     = var.lockdown_default_seclist
  nat_gateway_enabled          = var.worker_mode == "private" || var.operator_enabled == true || (var.lb_subnet_type == "internal" || var.lb_subnet_type == "both") ? true : false
  nat_gateway_public_ip_id     = var.nat_gateway_public_ip_id
  service_gateway_enabled      = true
  tags                         = var.tags["vcn"]
  vcn_cidr                     = var.vcn_cidr
  vcn_dns_label                = var.vcn_dns_label
  vcn_name                     = var.vcn_name
  internet_gateway_route_rules = var.internet_gateway_route_rules
  nat_gateway_route_rules      = var.nat_gateway_route_rules

}

module "bastion" {
  source  = "oracle-terraform-modules/bastion/oci"
  version = "3.0.0-RC1"

  tenancy_id     = var.tenancy_id
  compartment_id = var.compartment_id

  label_prefix = var.label_prefix

  # networking
  availability_domain = var.availability_domains["bastion"]
  bastion_access      = var.bastion_access
  ig_route_id         = module.vcn.ig_route_id
  netnum              = var.netnum["bastion"]
  newbits             = var.newbits["bastion"]
  vcn_id              = module.vcn.vcn_id

  # bastion host parameters
  create_bastion_host = var.bastion_enabled
  bastion_image_id    = var.bastion_image_id
  bastion_os_version  = var.bastion_operating_system_version
  bastion_shape       = var.bastion_shape
  bastion_state       = var.bastion_state
  bastion_timezone    = var.bastion_timezone
  bastion_type        = var.bastion_type

  ssh_public_key      = var.ssh_public_key
  ssh_public_key_path = var.ssh_public_key_path
  upgrade_bastion     = var.bastion_package_upgrade

  # bastion notification
  enable_bastion_notification   = var.bastion_notification_enabled
  bastion_notification_endpoint = var.bastion_notification_endpoint
  bastion_notification_protocol = var.bastion_notification_protocol
  bastion_notification_topic    = var.bastion_notification_topic

  bastion_tags = var.tags["bastion"]

  providers = {
    oci.home = oci.home
  }
}

module "operator" {
  source  = "oracle-terraform-modules/operator/oci"
  version = "3.0.0-RC1"

  tenancy_id = var.tenancy_id

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # networking
  availability_domain = var.availability_domains["operator"]
  nat_route_id        = module.vcn.nat_route_id
  netnum              = var.netnum["operator"]
  newbits             = var.newbits["operator"]
  nsg_ids             = var.nsg_ids
  vcn_id              = module.vcn.vcn_id

  # bastion host parameters
  create_operator             = var.operator_enabled
  operator_image_id           = var.operator_image_id
  operator_instance_principal = var.operator_instance_principal
  operator_os_version         = var.operator_version
  operator_shape              = var.operator_shape
  operator_state              = var.operator_state
  operator_timezone           = var.operator_timezone
  ssh_public_key              = var.ssh_public_key
  ssh_public_key_path         = var.ssh_public_key_path
  upgrade_operator            = var.operator_package_upgrade

  # operator notification
  enable_operator_notification   = var.operator_notification_enabled
  operator_notification_endpoint = var.operator_notification_endpoint
  operator_notification_protocol = var.operator_notification_protocol
  operator_notification_topic    = var.operator_notification_topic

  tags = var.tags["operator"]

  providers = {
    oci.home = oci.home
  }
}

module "policies" {
  source = "./modules/policies"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # provider
  tenancy_id = var.tenancy_id

  # ssh keys
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path

  # bastion and operator details
  bastion_public_ip           = module.bastion.bastion_public_ip
  operator_private_ip         = module.operator.operator_private_ip
  bastion_enabled             = var.bastion_enabled
  operator_enabled            = var.operator_enabled
  operator_instance_principal = var.operator_instance_principal
  bastion_state               = var.bastion_state


  dynamic_group = module.operator.operator_instance_principal_group_name

  # kms integration
  key_id         = var.existing_key_id
  use_encryption = var.use_encryption

  cluster_id = module.oke.cluster_id

  providers = {
    oci.home = oci.home
  }
}

# additional networking for oke
module "network" {
  source = "./modules/okenetwork"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # oke networking parameters
  ig_route_id  = module.vcn.ig_route_id
  nat_route_id = module.vcn.nat_route_id
  netnum       = var.netnum
  newbits      = var.newbits
  vcn_cidr     = var.vcn_cidr
  vcn_id       = module.vcn.vcn_id

  # control plane endpoint parameters
  cluster_access        = var.cluster_access
  cluster_access_source = var.cluster_access_source

  # oke worker network parameters
  allow_node_port_access  = var.allow_node_port_access
  allow_worker_ssh_access = var.allow_worker_ssh_access
  worker_mode             = var.worker_mode

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

  # provider
  tenancy_id = var.tenancy_id

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # region parameters
  # ad_names = module.base.ad_names
  region = var.region

  # ssh keys
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path

  # bastion and operator details
  bastion_public_ip           = module.bastion.bastion_public_ip
  operator_private_ip         = module.operator.operator_private_ip
  bastion_enabled             = var.bastion_enabled
  operator_enabled            = var.operator_enabled
  operator_instance_principal = var.operator_instance_principal
  operator_version            = var.operator_version
  bastion_state               = var.bastion_state

  # oke cluster parameters
  cluster_kubernetes_version                              = var.kubernetes_version
  cluster_access                                          = var.cluster_access
  cluster_name                                            = var.cluster_name
  cluster_options_add_ons_is_kubernetes_dashboard_enabled = var.dashboard_enabled
  cluster_options_kubernetes_network_config_pods_cidr     = var.pods_cidr
  cluster_options_kubernetes_network_config_services_cidr = var.services_cidr
  cluster_subnets                                         = module.network.subnet_ids
  vcn_id                                                  = module.vcn.vcn_id
  use_encryption                                          = var.use_encryption
  kms_key_id                                              = var.existing_key_id
  use_signed_images                                       = var.use_signed_images
  image_signing_keys                                      = var.image_signing_keys
  admission_controller_options                            = var.admission_controller_options

  # oke node pool parameters
  node_pools            = var.node_pools
  node_pool_name_prefix = var.node_pool_name_prefix
  node_pool_image_id    = var.node_pool_image_id
  node_pool_os          = var.node_pool_os
  node_pool_os_version  = var.node_pool_os_version

  # oke load balancer parameters
  preferred_lb_subnets = var.preferred_lb_subnets

  # ocir parameters
  email_address = var.email_address
  ocir_urls     = var.ocir_urls
  secret_id     = var.secret_id
  secret_name   = var.secret_name
  username      = var.username

  # calico parameters
  calico_version = var.calico_version
  install_calico = var.calico_enabled

  # metric server
  metricserver_enabled = var.metricserver_enabled
  vpa_enabled          = var.vpa_enabled
  vpa_version          = var.vpa_version

  # service account
  create_service_account               = var.create_service_account
  service_account_name                 = var.service_account_name
  service_account_namespace            = var.service_account_namespace
  service_account_cluster_role_binding = var.service_account_cluster_role_binding

  #check worker nodes are active
  check_node_active = var.check_node_active

  nodepool_drain = var.nodepool_drain

  nodepool_upgrade_method = var.nodepool_upgrade_method

  node_pools_to_drain = var.node_pools_to_drain

}
