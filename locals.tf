# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  
  oci_base_provider = {
    api_fingerprint      = var.api_fingerprint
    api_private_key_path = var.api_private_key_path
    region               = var.region
    tenancy_id           = var.tenancy_id
    user_id              = var.user_id
  }

  
  oci_base_ssh_keys = {
    ssh_private_key_path = var.ssh_private_key_path
    ssh_public_key_path  = var.ssh_public_key_path
  }

  

  oke_network_vcn = {
    ig_route_id  = var.ig_route_id
    nat_route_id = var.nat_route_id
    netnum       = var.netnum
    newbits      = var.newbits
    vcn_cidr     = data.oci_core_vcn.oke_vcn.cidr_block
    vcn_id       = var.vcn_id
  }

  oke_network_worker = {
    allow_node_port_access  = var.allow_node_port_access
    allow_worker_ssh_access = var.allow_worker_ssh_access
    worker_mode             = var.worker_mode
  }

   oke_operator = {
    bastion_public_ip           = var.bastion_public_ip
    operator_private_ip         = var.operator_private_ip
    bastion_enabled             = var.bastion_enabled
    operator_enabled            = var.operator_enabled
    operator_instance_principal = var.operator_instance_principal
  }

  oke_cluster = {
    cluster_kubernetes_version                              = var.kubernetes_version
    cluster_name                                            = var.cluster_name
    cluster_options_add_ons_is_kubernetes_dashboard_enabled = var.dashboard_enabled
    cluster_options_kubernetes_network_config_pods_cidr     = var.pods_cidr
    cluster_options_kubernetes_network_config_services_cidr = var.services_cidr
    cluster_subnets                                         = module.network.subnet_ids
    vcn_id                                                  = var.vcn_id
    use_encryption                                          = var.use_encryption
    kms_key_id                                              = var.existing_key_id
  }

  node_pools = {
    node_pools            = var.node_pools
    node_pool_name_prefix = var.node_pool_name_prefix
    node_pool_image_id    = var.node_pool_image_id
    node_pool_os          = var.node_pool_os
    node_pool_os_version  = var.node_pool_os_version
  }

  lbs = {
    preferred_lb_subnets = var.preferred_lb_subnets
  }

  oke_ocir = {
    email_address = var.email_address
    ocir_urls     = var.ocir_urls
    tenancy_name  = var.tenancy_name
    username      = var.username
    secret_id     = var.secret_id
  }

  helm = {
    helm_enabled = var.helm_enabled
    helm_version = var.helm_version
  }

  calico = {
    calico_enabled = var.calico_enabled
    calico_version = var.calico_version
  }

  oke_kms = {
    use_encryption = var.use_encryption
    key_id         = var.existing_key_id
  }

  service_account = {
    create_service_account               = var.create_service_account
    service_account_name                 = var.service_account_name
    service_account_namespace            = var.service_account_namespace
    service_account_cluster_role_binding = var.service_account_cluster_role_binding
  }
}
