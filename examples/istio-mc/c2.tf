# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "c2" {

  source  = "oracle-terraform-modules/oke/oci"
  version = "5.1.1"

  count = lookup(lookup(var.clusters, "c2"), "enabled") ? 1 : 0

  home_region = lookup(local.regions, var.home_region)
  
  region      = lookup(local.regions, lookup(lookup(var.clusters, "c2"), "region"))

  tenancy_id = var.tenancy_id

  # general oci parameters
  compartment_id = var.compartment_id

  # ssh keys
  ssh_private_key_path = var.ssh_private_key_path
  ssh_public_key_path  = var.ssh_public_key_path

  # networking
  create_drg       = var.oke_control_plane == "private" ? true : false
  drg_display_name = "c2"

  remote_peering_connections = var.oke_control_plane == "private" ? {
    for k, v in var.clusters : "rpc-to-${k}" => {} if k != "c2"
  } : {}

  nat_gateway_route_rules = var.oke_control_plane == "private" ? [
    for k, v in var.clusters :
    {
      destination       = lookup(v, "vcn")
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "drg"
      description       = "Routing to allow connectivity to ${title(k)} cluster"
    } if k != "c2"
  ] : []

  vcn_cidrs     = [lookup(lookup(var.clusters, "c2"), "vcn")]
  vcn_dns_label = "c2"
  vcn_name      = "c2"

  #subnets
  subnets = {
    cp      = { newbits = 13, netnum = 2, dns_label = "cp" }
    int_lb  = { newbits = 11, netnum = 16, dns_label = "ilb" }
    pub_lb  = { newbits = 11, netnum = 17, dns_label = "plb" }
    workers = { newbits = 2, netnum = 1, dns_label = "workers" }
    pods    = { newbits = 2, netnum = 2, dns_label = "pods" }
  }

  # bastion host
  create_bastion        = false
  bastion_allowed_cidrs = ["0.0.0.0/0"]
  bastion_upgrade       = false

  # operator host
  create_operator            = false
  operator_upgrade           = false
  create_iam_resources       = true
  create_iam_operator_policy = "always"
  operator_install_k9s       = true

  # oke cluster options
  cluster_name                = "c2"
  cluster_type                = var.cluster_type
  cni_type                    = var.preferred_cni
  control_plane_is_public     = var.oke_control_plane == "public"
  control_plane_allowed_cidrs = [local.anywhere]
  kubernetes_version          = var.kubernetes_version
  pods_cidr                   = lookup(lookup(var.clusters, "c2"), "pods")
  services_cidr               = lookup(lookup(var.clusters, "c2"), "services")


  # node pools
  kubeproxy_mode                    = "iptables"
  worker_pool_mode                  = "node-pool"
  worker_pools                      = var.nodepools
  worker_cloud_init                 = local.worker_cloud_init
  worker_image_type                 = "oke"

  # oke load balancers
  load_balancers          = "both"
  preferred_load_balancer = "public"

  allow_rules_internal_lb = {
    for p in local.service_mesh_ports :

    format("Allow ingress to port %v", p) => {
      protocol = local.tcp_protocol, port = p, source = lookup(lookup(var.clusters, "c1"), "vcn"), source_type = local.rule_type_cidr,
    }
  }

  allow_rules_public_lb = {

    for p in local.public_lb_allowed_ports :

    format("Allow ingress to port %v", p) => {
      protocol = local.tcp_protocol, port = p, source = "0.0.0.0/0", source_type = local.rule_type_cidr,
    }
  }

  user_id = var.user_id

  providers = {
    oci      = oci.c2
    oci.home = oci.home
  }
}
