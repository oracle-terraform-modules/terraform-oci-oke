# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_instance" "admin" {
  availability_domain = element(var.oci_admin_network.ad_names, (var.oci_admin_network.availability_domains - 1))
  compartment_id      = var.oci_admin_identity.compartment_id

  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.admin[0].id
    display_name     = "${var.oci_admin_general.label_prefix}-admin-vnic"
    hostname_label   = "admin"
  }

  display_name = "${var.oci_admin_general.label_prefix}-admin"

  extended_metadata = {
    ssh_authorized_keys = file(var.oci_admin.ssh_public_key_path)
    user_data           = data.template_cloudinit_config.admin[0].rendered
    subnet_id           = oci_core_subnet.admin[0].id
  }

  # prevent the bastion from destroying and recreating itself if the image ocid changes 
  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }

  shape = var.oci_admin.admin_shape

  source_details {
    source_type = "image"
    source_id   = var.oci_admin.admin_image_id == "NONE" ? data.oci_core_images.admin_images.images.0.id : var.oci_admin.image_id
  }

  timeouts {
    create = "60m"
  }

  count = var.oci_admin.admin_enabled == true ? 1 : 0
}
