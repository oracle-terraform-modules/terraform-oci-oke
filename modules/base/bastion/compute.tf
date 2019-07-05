# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_core_images" "bastion_images" {
  compartment_id = var.compartment_ocid

  operating_system         = var.image_operating_system
  operating_system_version = var.image_operating_system_version
  shape                    = var.bastion_shape
}
resource "oci_core_instance" "bastion" {
  availability_domain = element(var.ad_names, (var.availability_domains["bastion"]-1))
  compartment_id      = var.compartment_ocid

  create_vnic_details {
    subnet_id      = oci_core_subnet.bastion[0].id
    display_name   = "${var.label_prefix}-bastion-vnic"
    hostname_label = "bastion"
  }

  display_name = "${var.label_prefix}-bastion"

  extended_metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = data.template_cloudinit_config.bastion[0].rendered
    subnet_id           = oci_core_subnet.bastion[0].id
  }

  shape = var.bastion_shape

  source_details {
    source_type = "image"
    source_id   = var.image_ocid == "NONE" ? data.oci_core_images.bastion_images.images.0.id : var.image_ocid
  }

  timeouts {
    create = "60m"
  }

  count = var.create_bastion == true ? 1 : 0
}
