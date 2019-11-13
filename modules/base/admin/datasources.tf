# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_images" "admin_images" {
  compartment_id           = var.oci_admin_identity.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "7.7"
  shape                    = var.oci_admin.admin_shape
  sort_by                  = "TIMECREATED"
}

data "template_file" "admin_template" {
  template = file("${path.module}/scripts/admin.template.sh")
  count    = var.oci_admin.admin_enabled == true ? 1 : 0
}


data "template_file" "admin_cloud_init_file" {
  template = file("${path.module}/cloudinit/admin.template.yaml")

  vars = {
    admin_sh_content = base64gzip(data.template_file.admin_template[0].rendered)
    admin_upgrade    = var.oci_admin.admin_upgrade
    timezone         = var.oci_admin.timezone
  }
  count = var.oci_admin.admin_enabled == true ? 1 : 0
}

# cloud init for admin
data "template_cloudinit_config" "admin" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "admin.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.admin_cloud_init_file[0].rendered
  }
  count = var.oci_admin.admin_enabled == true ? 1 : 0
}

# Gets a list of VNIC attachments on the admin instance
data "oci_core_vnic_attachments" "admin_vnics_attachments" {
  availability_domain = element(var.oci_admin_network.ad_names, (var.oci_admin_network.availability_domains - 1))
  compartment_id      = var.oci_admin_identity.compartment_id
  instance_id         = oci_core_instance.admin[0].id
  count               = var.oci_admin.admin_enabled == true ? 1 : 0
}

# Gets the OCID of the first (default) VNIC on the admin instance
data "oci_core_vnic" "admin_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.admin_vnics_attachments[0].vnic_attachments[0], "vnic_id")
  count   = var.oci_admin.admin_enabled == true ? 1 : 0
}

data "oci_core_instance" "admin" {
  #Required
  instance_id = oci_core_instance.admin[0].id
  count       = var.oci_admin.admin_enabled == true ? 1 : 0
}
