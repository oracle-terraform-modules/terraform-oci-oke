# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "bastion_template" {
  template = "${file("${path.module}/scripts/bastion.template.sh")}"

  vars = {
    user = "${var.preferred_bastion_image == "ubuntu" ? "ubuntu" : "opc" }"
  }

  count = "${var.availability_domains["bastion_ad1"] == "true" || var.availability_domains["bastion_ad2"] == "true" || var.availability_domains["bastion_ad3"] == "true"   ? "1" : "0"}"
}

data "template_file" "bastion_cloud_init_file" {
  template = "${file("${path.module}/cloudinit/bastion.template.yaml")}"

  vars = {
    bastion_sh_content = "${base64gzip(data.template_file.bastion_template.rendered)}"
    user               = "${var.preferred_bastion_image == "ubuntu" ? "ubuntu" : "opc" }"
  }

  count = "${var.availability_domains["bastion_ad1"] == "true" || var.availability_domains["bastion_ad2"] == "true" || var.availability_domains["bastion_ad3"] == "true"   ? "1" : "0"}"
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

  count = "${var.availability_domains["bastion_ad1"] == "true" || var.availability_domains["bastion_ad2"] == "true" || var.availability_domains["bastion_ad3"] == "true"   ? "1" : "0"}"
}

# Gets a list of VNIC attachments on the bastion instance in AD 1
data "oci_core_vnic_attachments" "bastion_vnics_attachments_ad1" {
  count               = "${(var.availability_domains["bastion_ad1"] == "true") ? "1" : "0"}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${element(var.ad_names, 0)}"
  instance_id         = "${oci_core_instance.bastion_ad1.id}"
}

# Gets the OCID of the first (default) VNIC on the bastion instance in AD 1
data "oci_core_vnic" "bastion_vnic_ad1" {
  count   = "${(var.availability_domains["bastion_ad1"] == "true") ? "1" : "0"}"
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics_attachments_ad1.vnic_attachments[0],"vnic_id")}"
}

# Gets a list of VNIC attachments on the bastion instance in AD 2
data "oci_core_vnic_attachments" "bastion_vnics_attachments_ad2" {
  count               = "${(var.availability_domains["bastion_ad2"] == "true") ? "1" : "0"}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${element(var.ad_names, 1)}"
  instance_id         = "${oci_core_instance.bastion_ad2.id}"
}

# Gets the OCID of the first (default) VNIC on the bastion instance in AD 2
data "oci_core_vnic" "bastion_vnic_ad2" {
  count   = "${(var.availability_domains["bastion_ad2"] == "true") ? "1" : "0"}"
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics_attachments_ad2.vnic_attachments[0],"vnic_id")}"
}

# Gets a list of VNIC attachments on the bastion instance in AD 3
data "oci_core_vnic_attachments" "bastion_vnics_attachments_ad3" {
  count               = "${(var.availability_domains["bastion_ad3"] == "true") ? "1" : "0"}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${element(var.ad_names, 2)}"
  instance_id         = "${oci_core_instance.bastion_ad3.id}"
}

# Gets the OCID of the first (default) VNIC on the bastion instance in AD 3
data "oci_core_vnic" "bastion_vnic_ad3" {
  count   = "${(var.availability_domains["bastion_ad3"] == "true") ? "1" : "0"}"
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics_attachments_ad3.vnic_attachments[0],"vnic_id")}"
}
