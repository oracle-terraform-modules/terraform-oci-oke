# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl
data "template_file" "bastion_template" {
  template = "${file("${path.module}/scripts/bastion.template.sh")}"

  vars = {
    user = "${var.image_operating_system == "Canonical Ubuntu" ? "ubuntu" : "opc" }"
  }

  count = "${var.create_bastion == true  ? 1 : 0}"
}

data "template_file" "bastion_cloud_init_file" {
  template = "${file("${path.module}/cloudinit/bastion.template.yaml")}"

  vars = {
    bastion_sh_content = "${base64gzip(data.template_file.bastion_template.rendered)}"
    user = "${var.image_operating_system == "Canonical Ubuntu" ? "ubuntu" : "opc" }"
  }

  count = "${var.create_bastion == true  ? 1 : 0}"
}

# cloud init for bastion
data "template_cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "bastion.yaml"
    content_type = "text/cloud-config"
    content      = "${data.template_file.bastion_cloud_init_file.rendered}"
  }

  count = "${var.create_bastion == true  ? 1 : 0}"
}

# Gets a list of VNIC attachments on the bastion instance
data "oci_core_vnic_attachments" "bastion_vnics_attachments" {
  availability_domain = "${element(var.ad_names, (var.availability_domains["bastion"]-1))}"
  compartment_id      = "${var.compartment_ocid}"
  instance_id         = "${oci_core_instance.bastion.id}"
  count               = "${(var.create_bastion == true) ? 1 : 0}"
}

# Gets the OCID of the first (default) VNIC on the bastion instance
data "oci_core_vnic" "bastion_vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics_attachments.vnic_attachments[0],"vnic_id")}"
  count   = "${(var.create_bastion == true) ? 1 : 0}"
}

data "oci_core_instance" "bastion" {
  #Required
  instance_id = "${oci_core_instance.bastion.id}"
  count       = "${(var.create_bastion == true) ? 1 : 0}"
}
