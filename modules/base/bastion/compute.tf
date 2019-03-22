# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_core_instance" "bastion_ad1" {
  availability_domain = "${element(var.ad_names, 0)}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}-bastion_ad1"

  source_details {
    source_type = "image"
    source_id   = "${var.image_ocid}"
  }

  shape = "${var.bastion_shape}"

  create_vnic_details {
    subnet_id              = "${var.bastion_subnet_ids["ad1"]}"
    display_name           = "${var.label_prefix}-bastion_ad1-vnic"
    hostname_label         = "bastion-ad1"

  }

  extended_metadata {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}"
    user_data           = "${data.template_cloudinit_config.bastion.rendered}"
    subnet_id           = "${var.bastion_subnet_ids["ad1"]}"
    tags                = "group:bastion"
  }

  timeouts {
    create = "60m"
  }

  count = "${(var.availability_domains["bastion_ad1"] == "true") ? "1" : "0"}"
}

resource "oci_core_instance" "bastion_ad2" {
  availability_domain = "${element(var.ad_names, 1)}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}-bastion_ad2"

  source_details {
    source_type = "image"
    source_id   = "${var.image_ocid}"
  }

  shape = "${var.bastion_shape}"

  create_vnic_details {
    subnet_id              = "${var.bastion_subnet_ids["ad2"]}"
    display_name           = "${var.label_prefix}--bastion_ad2-vnic"
    hostname_label         = "bastion-ad2"

  }

  extended_metadata {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}"
    user_data           = "${data.template_cloudinit_config.bastion.rendered}"
    subnet_id           = "${var.bastion_subnet_ids["ad2"]}"
    tags                = "group:bastion"
  }

  timeouts {
    create = "60m"
  }

  count = "${(var.availability_domains["bastion_ad2"] == "true") ? "1" : "0"}"
}

resource "oci_core_instance" "bastion_ad3" {
  availability_domain = "${element(var.ad_names, 2)}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}-bastion_ad3"

  source_details {
    source_type = "image"
    source_id   = "${var.image_ocid}"
  }

  shape = "${var.bastion_shape}"

  create_vnic_details {
    subnet_id              = "${var.bastion_subnet_ids["ad3"]}"
    display_name           = "${var.label_prefix}--bastion_ad3-vnic"
    hostname_label         = "bastion-ad3"
    subnet_id              = "${var.bastion_subnet_ids["ad3"]}"

  }

  extended_metadata {
    ssh_authorized_keys = "${file(var.ssh_public_key_path)}"
    user_data           = "${data.template_cloudinit_config.bastion.rendered}"
    subnet_id           = "${var.bastion_subnet_ids["ad3"]}"
    tags                = "group:bastion"
  }

  timeouts {
    create = "60m"
  }

  count = "${(var.availability_domains["bastion_ad3"] == "true") ? "1" : "0"}"
}
