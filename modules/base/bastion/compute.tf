# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_instance" "bastion" {
  availability_domain = element(var.oci_bastion_infra.ad_names, (var.oci_bastion_infra.availability_domains - 1))
  compartment_id      = var.oci_base_identity.compartment_id

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.bastion[0].id
    display_name     = "${var.oci_bastion_general.label_prefix}-bastion-vnic"
    hostname_label   = "bastion"
  }

  display_name = "${var.oci_bastion_general.label_prefix}-bastion"

  extended_metadata = {
    ssh_authorized_keys = file(var.oci_bastion.ssh_public_key_path)
    subnet_id           = oci_core_subnet.bastion[0].id
    user_data           = data.template_cloudinit_config.bastion[0].rendered
  }

  shape = var.oci_bastion.bastion_shape

  source_details {
    source_type = "image"
    source_id   = local.bastion_image_id
  }

  timeouts {
    create = "60m"
  }

  count = var.oci_bastion.create_bastion == true ? 1 : 0
}