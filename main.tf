# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.0.0"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # gateways
  create_internet_gateway  = true
  create_nat_gateway       = var.worker_type == "private" || var.create_operator == true || (var.load_balancers == "internal" || var.load_balancers == "both") ? true : false
  create_service_gateway   = true
  nat_gateway_public_ip_id = var.nat_gateway_public_ip_id

  # drg
  create_drg       = var.create_drg
  drg_display_name = var.drg_display_name

  # lpgs
  local_peering_gateways = var.local_peering_gateways

  # freeform_tags
  freeform_tags = var.freeform_tags["vcn"]

  # vcn
  vcn_cidrs                    = var.vcn_cidrs
  vcn_dns_label                = var.vcn_dns_label
  vcn_name                     = var.vcn_name
  lockdown_default_seclist     = var.lockdown_default_seclist
  internet_gateway_route_rules = var.internet_gateway_route_rules
  nat_gateway_route_rules      = var.nat_gateway_route_rules

}

module "bastion" {
  source  = "oracle-terraform-modules/bastion/oci"
  version = "3.0.0"

  tenancy_id     = var.tenancy_id
  compartment_id = var.compartment_id

  label_prefix = var.label_prefix

  # networking
  availability_domain = var.availability_domains["bastion"]
  bastion_access      = var.bastion_access
  ig_route_id         = module.vcn.ig_route_id
  netnum              = lookup(var.subnets["bastion"], "netnum")
  newbits             = lookup(var.subnets["bastion"], "newbits")
  vcn_id              = module.vcn.vcn_id

  # bastion host parameters
  bastion_image_id   = var.bastion_image_id
  bastion_os_version = var.bastion_os_version
  bastion_shape      = var.bastion_shape
  bastion_state      = var.bastion_state
  bastion_timezone   = var.bastion_timezone
  bastion_type       = var.bastion_type

  ssh_public_key      = var.ssh_public_key
  ssh_public_key_path = var.ssh_public_key_path
  upgrade_bastion     = var.upgrade_bastion

  # bastion notification
  enable_bastion_notification   = var.enable_bastion_notification
  bastion_notification_endpoint = var.bastion_notification_endpoint
  bastion_notification_protocol = var.bastion_notification_protocol
  bastion_notification_topic    = var.bastion_notification_topic

  freeform_tags = var.freeform_tags["bastion"]

  providers = {
    oci.home = oci.home
  }

  depends_on = [
    module.vcn
  ]

  count = var.create_bastion_host == true ? 1 : 0
}

module "operator" {
  source  = "oracle-terraform-modules/operator/oci"
  version = "3.0.1"

  tenancy_id = var.tenancy_id

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # networking
  availability_domain = var.availability_domains["operator"]
  nat_route_id        = module.vcn.nat_route_id
  netnum              = lookup(var.subnets["operator"], "netnum")
  newbits             = lookup(var.subnets["operator"], "newbits")
  nsg_ids             = var.operator_nsg_ids
  vcn_id              = module.vcn.vcn_id

  # operator host parameters
  operator_image_id                  = var.operator_image_id
  enable_operator_instance_principal = var.enable_operator_instance_principal
  operator_os_version                = var.operator_os_version
  operator_shape                     = var.operator_shape
  operator_state                     = var.operator_state
  operator_timezone                  = var.operator_timezone
  ssh_public_key                     = var.ssh_public_key
  ssh_public_key_path                = var.ssh_public_key_path
  upgrade_operator                   = var.upgrade_operator

  # operator notification
  enable_operator_notification   = var.enable_operator_notification
  operator_notification_endpoint = var.operator_notification_endpoint
  operator_notification_protocol = var.operator_notification_protocol
  operator_notification_topic    = var.operator_notification_topic

  freeform_tags = var.freeform_tags["operator"]

  providers = {
    oci.home = oci.home
  }

  depends_on = [
    module.vcn
  ]

  count = var.create_operator == true ? 1 : 0
}

module "bastionsvc" {
  source = "./modules/bastionsvc"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # bastion service parameters
  bastion_service_access        = var.bastion_service_access
  bastion_service_name          = var.bastion_service_name
  bastion_service_target_subnet = var.bastion_service_target_subnet
  vcn_id                        = module.vcn.vcn_id

  depends_on = [
    module.operator
  ]

  count = var.create_bastion_service == true ? 1 : 0
}

# additional networking for oke
module "network" {
  source = "./modules/network"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # oke networking parameters
  ig_route_id  = module.vcn.ig_route_id
  nat_route_id = module.vcn.nat_route_id
  subnets      = var.subnets
  vcn_id       = module.vcn.vcn_id

  # control plane endpoint parameters
  control_plane_type          = var.control_plane_type
  control_plane_allowed_cidrs = var.control_plane_allowed_cidrs

  # oke worker network parameters
  allow_node_port_access       = var.allow_node_port_access
  allow_worker_internet_access = var.allow_worker_internet_access
  allow_worker_ssh_access      = var.allow_worker_ssh_access
  worker_type                  = var.worker_type

  # oke load balancer network parameters
  load_balancers = var.load_balancers

  # oke internal load balancer
  internal_lb_allowed_cidrs = var.internal_lb_allowed_cidrs
  internal_lb_allowed_ports = var.internal_lb_allowed_ports

  # oke public load balancer
  public_lb_allowed_cidrs = var.public_lb_allowed_cidrs
  public_lb_allowed_ports = var.public_lb_allowed_ports

  # waf integration
  enable_waf = var.enable_waf

  depends_on = [
    module.vcn
  ]
}

# cluster creation for oke
module "oke" {
  source = "./modules/oke"

  # provider
  tenancy_id = var.tenancy_id

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # ssh keys
  ssh_public_key      = var.ssh_public_key
  ssh_public_key_path = var.ssh_public_key_path

  # oke cluster parameters
  cluster_kubernetes_version                              = var.kubernetes_version
  control_plane_type                                      = var.control_plane_type
  control_plane_nsgs                                      = concat(var.control_plane_nsgs, [module.network.control_plane_nsg_id])
  cluster_name                                            = var.cluster_name
  cluster_options_add_ons_is_kubernetes_dashboard_enabled = var.dashboard_enabled
  cluster_options_kubernetes_network_config_pods_cidr     = var.pods_cidr
  cluster_options_kubernetes_network_config_services_cidr = var.services_cidr
  cluster_subnets                                         = module.network.subnet_ids
  vcn_id                                                  = module.vcn.vcn_id
  use_encryption                                          = var.use_encryption
  kms_key_id                                              = var.kms_key_id
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
  preferred_load_balancer = var.preferred_load_balancer

  # worker nsgs
  worker_nsgs = concat(var.worker_nsgs, [module.network.worker_nsg_id])

  depends_on = [
    module.network
  ]

  providers = {
    oci.home = oci.home
  }
}

# extensions to oke
module "extensions" {
  source = "./modules/extensions"

  # provider
  tenancy_id = var.tenancy_id

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix

  # region parameters
  region = var.region

  # ssh keys
  ssh_private_key      = var.ssh_private_key
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key       = var.ssh_public_key
  ssh_public_key_path  = var.ssh_public_key_path

  # bastion
  create_bastion_host = var.create_bastion_host
  bastion_public_ip   = local.bastion_public_ip
  bastion_state       = var.bastion_state

  # operator details
  create_operator                    = var.create_operator
  operator_private_ip                = local.operator_private_ip
  operator_state                     = var.operator_state
  operator_dynamic_group             = local.operator_instance_principal_group_name
  enable_operator_instance_principal = var.enable_operator_instance_principal
  operator_os_version                = var.operator_os_version

  # oke cluster parameters
  cluster_id           = module.oke.cluster_id
  pods_cidr            = var.pods_cidr
  use_encryption       = var.use_encryption
  kms_key_id           = var.kms_key_id
  kms_dynamic_group_id = module.oke.kms_dynamic_group_id

  # ocir parameters
  email_address    = var.email_address
  secret_id        = var.secret_id
  secret_name      = var.secret_name
  secret_namespace = var.secret_namespace
  username         = var.username

  # calico parameters
  calico_version = var.calico_version
  install_calico = var.enable_calico

  # metric server
  enable_metric_server = var.enable_metric_server
  enable_vpa           = var.enable_vpa
  vpa_version          = var.vpa_version

  #Gatekeeper
  enable_gatekeeper   = var.enable_gatekeeper
  gatekeeeper_version = var.gatekeeeper_version

  # service account
  create_service_account               = var.create_service_account
  service_account_name                 = var.service_account_name
  service_account_namespace            = var.service_account_namespace
  service_account_cluster_role_binding = var.service_account_cluster_role_binding

  #check worker nodes are active
  check_node_active = var.check_node_active

  # oke upgrade
  upgrade_nodepool        = var.upgrade_nodepool
  nodepool_upgrade_method = var.nodepool_upgrade_method
  node_pools_to_drain     = var.node_pools_to_drain

  debug_mode = var.debug_mode

  depends_on = [
    module.bastion,
    module.network,
    module.operator,
    module.oke
  ]

  providers = {
    oci.home = oci.home
  }
}
