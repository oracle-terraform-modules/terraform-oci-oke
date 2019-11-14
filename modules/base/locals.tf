# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  oci_base_vcn = {
    compartment_id          = var.oci_base_identity.compartment_id
    label_prefix            = var.oci_base_general.label_prefix
    nat_gateway_enabled     = var.oci_base_vcn.nat_gateway_enabled
    service_gateway_enabled = var.oci_base_vcn.service_gateway_enabled
    vcn_cidr                = var.oci_base_vcn.vcn_cidr
    vcn_dns_label           = var.oci_base_vcn.vcn_dns_label
    vcn_name                = var.oci_base_vcn.vcn_name
  }

  oci_bastion_general = {
    label_prefix = var.oci_base_general.label_prefix
    home_region  = lookup(data.oci_identity_regions.home_region.regions[0], "name")
    region       = var.oci_base_general.region
  }

  oci_bastion_infra = {
    ad_names             = data.template_file.ad_names.*.rendered
    availability_domains = var.oci_base_bastion.availability_domains
    ig_route_id          = module.vcn.ig_route_id
    netnum               = var.oci_base_bastion.netnum
    newbits              = var.oci_base_bastion.newbits
    vcn_cidr             = var.oci_base_vcn.vcn_cidr
    vcn_id               = module.vcn.vcn_id
  }

  oci_bastion = {
    bastion_access      = var.oci_base_bastion.bastion_access
    bastion_image_id    = var.oci_base_bastion.bastion_image_id
    bastion_shape       = var.oci_base_bastion.bastion_shape
    bastion_upgrade     = var.oci_base_bastion.bastion_upgrade
    bastion_enabled     = var.oci_base_bastion.bastion_enabled
    ssh_public_key_path = var.oci_base_bastion.ssh_public_key_path
    timezone            = var.oci_base_bastion.timezone
    use_autonomous      = var.oci_base_bastion.use_autonomous
  }

  oci_bastion_notification = {
    notification_enabled  = var.oci_base_bastion.notification_enabled
    notification_endpoint = var.oci_base_bastion.notification_endpoint
    notification_protocol = var.oci_base_bastion.notification_protocol
    notification_topic    = var.oci_base_bastion.notification_topic
  }

  oci_admin_network = {
    ad_names             = data.template_file.ad_names.*.rendered
    availability_domains = var.oci_base_admin.availability_domains
    nat_route_id         = module.vcn.nat_route_id
    netnum               = var.oci_base_admin.netnum
    newbits              = var.oci_base_admin.newbits
    vcn_cidr             = var.oci_base_vcn.vcn_cidr
    vcn_id               = module.vcn.vcn_id
  }

  oci_admin = {
    admin_image_id      = var.oci_base_admin.admin_image_id
    admin_shape         = var.oci_base_admin.admin_shape
    admin_upgrade       = var.oci_base_admin.admin_upgrade
    admin_enabled       = var.oci_base_admin.admin_enabled
    ssh_public_key_path = var.oci_base_admin.ssh_public_key_path
    timezone            = var.oci_base_admin.timezone
  }

  oci_admin_notification = {
    enable_notification   = var.oci_base_admin.notification_enabled
    notification_endpoint = var.oci_base_admin.notification_endpoint
    notification_protocol = var.oci_base_admin.notification_protocol
    notification_topic    = var.oci_base_admin.notification_topic
  }
}
