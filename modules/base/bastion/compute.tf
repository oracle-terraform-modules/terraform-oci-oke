# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_instance" "bastion" {
  availability_domain = "${element(var.ad_names, (var.availability_domains["bastion"]-1))}"
  compartment_id      = "${var.compartment_ocid}"

  create_vnic_details {
    subnet_id      = "${oci_core_subnet.bastion.id}"
    display_name   = "${var.label_prefix}-bastion-vnic"
    hostname_label = "bastion"
  }

  display_name = "${var.label_prefix}-bastion"

  extended_metadata {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}"
    user_data           = "${data.template_cloudinit_config.bastion.rendered}"
    subnet_id           = "${oci_core_subnet.bastion.id}"
  }

  shape = "${var.bastion_shape}"

  source_details {
    source_type = "image"
    source_id   = "${var.image_ocid}"
  }

  timeouts {
    create = "60m"
  }

  count = "${(var.create_bastion == true) ? 1 : 0}"
}
