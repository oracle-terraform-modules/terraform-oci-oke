# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {

  oci_base_general = {
    compartment_id      = var.compartment_id
    label_prefix        = var.label_prefix
    root_compartment_id = var.tenancy_id
  }

  oci_base_provider = {
    api_fingerprint      = var.api_fingerprint
    api_private_key_path = var.api_private_key_path
    region               = var.region
    tenancy_id           = var.tenancy_id
    user_id              = var.user_id
  }

  oci_base_vcn = {
    create_drg                   = var.create_drg
    drg_display_name             = var.drg_display_name
    internet_gateway_enabled     = true
    lockdown_default_seclist     = var.lockdown_default_seclist
    nat_gateway_enabled          = var.worker_mode == "private" || var.operator_enabled == true || (var.lb_subnet_type == "internal" || var.lb_subnet_type == "both") ? true : false
    service_gateway_enabled      = true
    tags                         = var.tags["vcn"]
    vcn_cidr                     = var.vcn_cidr
    vcn_dns_label                = var.vcn_dns_label
    vcn_name                     = var.vcn_name
    internet_gateway_route_rules = var.internet_gateway_route_rules
    nat_gateway_route_rules      = var.nat_gateway_route_rules
  }

  oci_base_ssh_keys = {
    ssh_private_key_path = var.ssh_private_key_path
    ssh_public_key_path  = var.ssh_public_key_path
  }

  oci_base_bastion = {
    availability_domain   = var.availability_domains["bastion"]
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
    ssh_public_key        = var.ssh_public_key
    ssh_public_key_path   = var.ssh_public_key_path
    tags                  = var.tags["bastion"]
    timezone              = var.bastion_timezone
  }

  oci_base_operator = {
    availability_domain       = var.availability_domains["operator"]
    operator_enabled          = var.operator_enabled
    operator_image_id         = var.operator_image_id
    operator_shape            = var.operator_shape
    operating_system_version  = var.operator_version
    operator_upgrade          = var.operator_package_upgrade
    enable_instance_principal = var.operator_instance_principal
    netnum                    = var.netnum["operator"]
    newbits                   = var.newbits["operator"]
    notification_enabled      = var.operator_notification_enabled
    notification_endpoint     = var.operator_notification_endpoint
    notification_protocol     = var.operator_notification_protocol
    notification_topic        = var.operator_notification_topic
    ssh_private_key_path      = var.ssh_private_key_path
    ssh_public_key            = var.ssh_public_key
    ssh_public_key_path       = var.ssh_public_key_path
    tags                      = var.tags["bastion"]
    timezone                  = var.operator_timezone
  }

  oke_network_vcn = {
    ig_route_id  = module.base.ig_route_id
    nat_route_id = module.base.nat_route_id
    netnum       = var.netnum
    newbits      = var.newbits
    vcn_cidr     = var.vcn_cidr
    vcn_id       = module.base.vcn_id
  }

  oke_network_worker = {
    allow_node_port_access  = var.allow_node_port_access
    allow_worker_ssh_access = var.allow_worker_ssh_access
    worker_mode             = var.worker_mode
  }

  oke_operator = {
    bastion_public_ip           = module.base.bastion_public_ip
    operator_private_ip         = module.base.operator_private_ip
    bastion_enabled             = var.bastion_enabled
    operator_enabled            = var.operator_enabled
    operator_instance_principal = var.operator_instance_principal
    operator_version            = var.operator_version
  }

  oke_cluster = {
    cluster_kubernetes_version                              = var.kubernetes_version
    cluster_access                                          = var.cluster_access
    cluster_name                                            = var.cluster_name
    cluster_options_add_ons_is_kubernetes_dashboard_enabled = var.dashboard_enabled
    cluster_options_kubernetes_network_config_pods_cidr     = var.pods_cidr
    cluster_options_kubernetes_network_config_services_cidr = var.services_cidr
    cluster_subnets                                         = module.network.subnet_ids
    vcn_id                                                  = module.base.vcn_id
    use_encryption                                          = var.use_encryption
    kms_key_id                                              = var.existing_key_id
    use_signed_images                                       = var.use_signed_images
    image_signing_keys                                      = var.image_signing_keys
    admission_controller_options                            = var.admission_controller_options
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
    secret_id     = var.secret_id
    secret_name   = var.secret_name
    username      = var.username
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
