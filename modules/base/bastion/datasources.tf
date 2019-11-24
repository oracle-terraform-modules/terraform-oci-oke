# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

data "oci_core_app_catalog_listings" "autonomous_linux" {
  display_name = "Oracle Autonomous Linux"
  count        = var.oci_bastion.use_autonomous == true ? 1 : 0
}

data "oci_core_app_catalog_listing_resource_versions" "autonomous_linux" {
  #Required
  listing_id = lookup(data.oci_core_app_catalog_listings.autonomous_linux[0].app_catalog_listings[0], "listing_id")
  count      = var.oci_bastion.use_autonomous == true ? 1 : 0
}

# Gets the Autonomous Linux image id
data "oci_core_app_catalog_subscriptions" "autonomous_linux" {
  #Required
  compartment_id = var.oci_base_identity.compartment_id

  #Optional
  listing_id = lookup(data.oci_core_app_catalog_listing_resource_versions.autonomous_linux[0].app_catalog_listing_resource_versions[0], "listing_id")
  count      = var.oci_bastion.use_autonomous == true ? 1 : 0
}

data "template_file" "autonomous_template" {
  template = file("${path.module}/scripts/notification.template.sh")

  vars = {
    notification_enabled = var.oci_bastion_notification.notification_enabled
    topic_id             = var.oci_bastion_notification.notification_enabled == true ? oci_ons_notification_topic.bastion_notification[0].topic_id : "null"
  }
  count = var.oci_bastion.bastion_enabled == true && var.oci_bastion.use_autonomous == true ? 1 : 0
}

data "template_file" "autonomous_cloud_init_file" {
  template = file("${path.module}/cloudinit/autonomous.template.yaml")

  vars = {
    notification_sh_content = base64gzip(data.template_file.autonomous_template[0].rendered)
    timezone                = var.oci_bastion.timezone
  }
  count = var.oci_bastion.bastion_enabled == true && var.oci_bastion.use_autonomous == true ? 1 : 0
}

data "oci_core_images" "oracle_images" {
  compartment_id           = var.oci_base_identity.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "7.7"
  shape                    = var.oci_bastion.bastion_shape
  sort_by                  = "TIMECREATED"
  count                    = var.oci_bastion.bastion_enabled == true && var.oci_bastion.use_autonomous == false ? 1 : 0
}

data "template_file" "oracle_template" {
  template = file("${path.module}/scripts/oracle.template.sh")
  count    = var.oci_bastion.bastion_enabled == true && var.oci_bastion.use_autonomous == false ? 1 : 0
}

data "template_file" "oracle_cloud_init_file" {
  template = file("${path.module}/cloudinit/oracle.template.yaml")

  vars = {
    bastion_sh_content      = base64gzip(data.template_file.oracle_template[0].rendered)
    bastion_package_upgrade = var.oci_bastion.bastion_upgrade
    timezone                = var.oci_bastion.timezone
  }
  count = var.oci_bastion.bastion_enabled == true && var.oci_bastion.use_autonomous == false ? 1 : 0
}

# cloud init for bastion
data "template_cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "bastion.yaml"
    content_type = "text/cloud-config"
    content      = var.oci_bastion.use_autonomous == true ? data.template_file.autonomous_cloud_init_file[0].rendered : data.template_file.oracle_cloud_init_file[0].rendered
  }
  count = var.oci_bastion.bastion_enabled == true ? 1 : 0
}

# Gets a list of VNIC attachments on the bastion instance
data "oci_core_vnic_attachments" "bastion_vnics_attachments" {
  availability_domain = element(var.oci_bastion_network.ad_names, (var.oci_bastion_network.availability_domains - 1))
  compartment_id      = var.oci_base_identity.compartment_id
  instance_id         = oci_core_instance.bastion[0].id
  depends_on          = [oci_core_instance.bastion]
  count               = var.oci_bastion.bastion_enabled == true ? 1 : 0
}

# Gets the OCID of the first (default) VNIC on the bastion instance
data "oci_core_vnic" "bastion_vnic" {
  vnic_id    = lookup(data.oci_core_vnic_attachments.bastion_vnics_attachments[0].vnic_attachments[0], "vnic_id")
  depends_on = [oci_core_instance.bastion]
  count      = var.oci_bastion.bastion_enabled == true ? 1 : 0
}

data "oci_core_instance" "bastion" {
  instance_id = oci_core_instance.bastion[0].id
  depends_on  = [oci_core_instance.bastion]
  count       = var.oci_bastion.bastion_enabled == true ? 1 : 0
}

data "oci_ons_notification_topic" "bastion_notification" {
  #Required
  topic_id = oci_ons_notification_topic.bastion_notification[0].topic_id
  count    = var.oci_bastion_notification.notification_enabled == true ? 1 : 0
}
