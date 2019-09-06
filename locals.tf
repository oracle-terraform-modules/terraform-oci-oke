# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {

  oci_base_identity = {
    api_fingerprint      = var.api_fingerprint
    api_private_key_path = var.api_private_key_path
    compartment_name     = var.compartment_name
    compartment_ocid     = var.compartment_ocid
    tenancy_ocid         = var.tenancy_ocid
    user_ocid            = var.user_ocid
  }

  oci_base_ssh_keys = {
    ssh_private_key_path = var.ssh_private_key_path
    ssh_public_key_path  = var.ssh_public_key_path
  }

  oci_base_general = {
    disable_auto_retries = var.disable_auto_retries
    label_prefix         = var.label_prefix
    region               = var.region
  }

  oci_base_vcn = {
    vcn_cidr               = var.vcn_cidr
    vcn_dns_name           = var.vcn_dns_name
    vcn_name               = var.vcn_name
    create_nat_gateway     = var.create_nat_gateway
    nat_gateway_name       = var.nat_gateway_name
    create_service_gateway = var.create_service_gateway
    service_gateway_name   = var.service_gateway_name
  }

  oci_base_bastion = {
    newbits                        = var.newbits["bastion"]
    subnets                        = var.subnets["bastion"]
    bastion_shape                  = var.bastion_shape
    create_bastion                 = var.create_bastion
    bastion_access                 = var.bastion_access
    enable_instance_principal      = var.enable_instance_principal
    image_ocid                     = var.image_ocid
    image_operating_system         = var.image_operating_system
    image_operating_system_version = var.image_operating_system_version
    availability_domains           = var.availability_domains["bastion"]
    package_update                 = var.package_update
    package_upgrade                = var.package_upgrade
  }

  ocir = {
    api_fingerprint      = var.api_fingerprint
    api_private_key_path = var.api_private_key_path
    compartment_ocid     = var.compartment_ocid
    create_auth_token    = var.create_auth_token
    home_region          = module.base.home_region
    tenancy_ocid         = var.tenancy_ocid
    user_ocid            = var.user_ocid
  }

  oke_general = {
    ad_names     = module.base.ad_names
    label_prefix = var.label_prefix
    region       = var.region
  }

  oke_network_vcn = {
    ig_route_id                = module.base.ig_route_id
    is_service_gateway_enabled = var.create_service_gateway
    nat_route_id               = module.base.nat_route_id
    newbits                    = var.newbits
    subnets                    = var.subnets
    vcn_cidr                   = var.vcn_cidr
    vcn_id                     = module.base.vcn_id
  }

  oke_network_worker = {
    allow_node_port_access  = var.allow_node_port_access
    allow_worker_ssh_access = var.allow_worker_ssh_access
    worker_mode             = var.worker_mode
  }

  oke_identity = {
    compartment_ocid = var.compartment_ocid
    user_ocid        = var.user_ocid
  }

  oke_bastion = {
    bastion_public_ip         = module.base.bastion_public_ip
    create_bastion            = var.create_bastion
    enable_instance_principal = var.enable_instance_principal
    image_operating_system    = var.image_operating_system
  }

  oke_cluster = {
    cluster_kubernetes_version                              = var.kubernetes_version
    cluster_name                                            = var.cluster_name
    cluster_options_add_ons_is_kubernetes_dashboard_enabled = var.dashboard_enabled
    cluster_options_add_ons_is_tiller_enabled               = var.tiller_enabled
    cluster_options_kubernetes_network_config_pods_cidr     = var.pods_cidr
    cluster_options_kubernetes_network_config_services_cidr = var.services_cidr
    cluster_subnets                                         = module.network.subnet_ids
    vcn_id                                                  = module.base.vcn_id
  }

  node_pools = {
    node_pools                    = var.node_pools
    node_pool_name_prefix         = var.node_pool_name_prefix
    node_pool_image_id            = var.node_pool_image_id
    node_pool_os                  = var.node_pool_os
    node_pool_os_version          = var.node_pool_os_version
    nodepool_topology             = var.nodepool_topology
  }

  lbs = {
    preferred_lb_ads     = var.preferred_lb_ads
    preferred_lb_subnets = var.preferred_lb_subnets
  }

  oke_ocir = {
    auth_token        = module.auth.ocirtoken
    create_auth_token = var.create_auth_token
    email_address     = var.email_address
    ocirtoken_id      = module.auth.ocirtoken_id
    ocir_urls         = var.ocir_urls
    tenancy_name      = var.tenancy_name
    username          = var.username
  }

  helm = {
    add_incubator_repo = var.add_incubator_repo
    add_jetstack_repo  = var.add_incubator_repo
    helm_version       = var.helm_version
    install_helm       = var.install_helm
  }

  calico = {
    calico_version = var.calico_version
    install_calico = var.install_calico
  }
}
