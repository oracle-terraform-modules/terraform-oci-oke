# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  oci_base_identity = {
    api_fingerprint      = var.api_fingerprint
    api_private_key_path = var.api_private_key_path
    compartment_id       = var.compartment_id
    tenancy_id           = var.tenancy_id
    user_id              = var.user_id
  }

  oci_base_ssh_keys = {
    ssh_private_key_path = var.ssh_private_key_path
    ssh_public_key_path  = var.ssh_public_key_path
  }

  oci_base_general = {
    label_prefix = var.label_prefix
    region       = var.region
  }

  oci_base_vcn = {
    nat_gateway_enabled     = var.nat_gateway_enabled
    service_gateway_enabled = true
    vcn_cidr                = var.vcn_cidr
    vcn_dns_label           = var.vcn_dns_label
    vcn_name                = var.vcn_name
  }

  oci_base_bastion = {
    availability_domains  = var.availability_domains["bastion"]
    bastion_access        = var.bastion_access
    bastion_enabled       = var.bastion_enabled
    bastion_image_id      = var.bastion_image_id
    bastion_shape         = var.bastion_shape
    bastion_upgrade       = var.bastion_package_upgrade
    netnum                = var.netnum["bastion"]
    newbits               = var.newbits["bastion"]
    notification_enabled  = var.bastion_notification_enabled
    notification_endpoint = var.bastion_notification_endpoint
    notification_protocol = var.bastion_notification_protocol
    notification_topic    = var.bastion_notification_topic
    ssh_private_key_path  = var.ssh_private_key_path
    ssh_public_key_path   = var.ssh_public_key_path
    timezone              = var.bastion_timezone
  }

  oci_base_admin = {
    availability_domains      = var.availability_domains["admin"]
    admin_enabled             = var.admin_enabled
    admin_image_id            = var.admin_image_id
    admin_shape               = var.admin_shape
    admin_upgrade             = var.admin_package_upgrade
    enable_instance_principal = var.admin_instance_principal
    netnum                    = var.netnum["admin"]
    newbits                   = var.newbits["admin"]
    notification_enabled      = var.admin_notification_enabled
    notification_endpoint     = var.admin_notification_endpoint
    notification_protocol     = var.admin_notification_protocol
    notification_topic        = var.admin_notification_topic
    ssh_private_key_path      = var.ssh_private_key_path
    ssh_public_key_path       = var.ssh_public_key_path
    timezone                  = var.admin_timezone
  }

  ocir = {
    api_fingerprint      = var.api_fingerprint
    api_private_key_path = var.api_private_key_path
    compartment_id       = var.compartment_id
    home_region          = module.base.home_region
    tenancy_id           = var.tenancy_id
    user_id              = var.user_id
    
  }

  oke_general = {
    ad_names     = module.base.ad_names
    label_prefix = var.label_prefix
    region       = var.region
  }

  oke_network_vcn = {
    ig_route_id                = module.base.ig_route_id
    nat_route_id               = module.base.nat_route_id
    netnum                     = var.netnum
    newbits                    = var.newbits
    vcn_cidr                   = var.vcn_cidr
    vcn_id                     = module.base.vcn_id
  }

  oke_network_worker = {
    allow_node_port_access  = var.allow_node_port_access
    allow_worker_ssh_access = var.allow_worker_ssh_access
    worker_mode             = var.worker_mode
  }

  oke_identity = {
    compartment_id = var.compartment_id
    user_id        = var.user_id
  }

  oke_admin = {
    bastion_public_ip        = module.base.bastion_public_ip
    admin_private_ip         = module.base.admin_private_ip
    bastion_enabled          = var.bastion_enabled
    admin_enabled            = var.admin_enabled
    admin_instance_principal = var.admin_instance_principal
  }

  oke_cluster = {
    cluster_kubernetes_version                              = var.kubernetes_version
    cluster_name                                            = var.cluster_name
    cluster_options_add_ons_is_kubernetes_dashboard_enabled = var.dashboard_enabled
    cluster_options_kubernetes_network_config_pods_cidr     = var.pods_cidr
    cluster_options_kubernetes_network_config_services_cidr = var.services_cidr
    cluster_subnets                                         = module.network.subnet_ids
    vcn_id                                                  = module.base.vcn_id
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
    email_address     = var.email_address
    ocir_urls         = var.ocir_urls
    tenancy_name      = var.tenancy_name
    username          = var.username
    secret_id         = var.secret_id
  }

  helm = {
    helm_version = var.helm_version
    install_helm = var.install_helm
  }

  calico = {
    calico_version = var.calico_version
    install_calico = var.install_calico
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
