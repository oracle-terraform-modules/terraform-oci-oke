# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_core_images" "bastion_images" {
  compartment_id           = var.oci_base_identity.compartment_ocid
  operating_system         = var.oci_bastion.image_operating_system
  operating_system_version = var.oci_bastion.image_operating_system_version
  shape                    = var.oci_bastion.bastion_shape
  sort_by                  = "TIMECREATED"
}

data "template_file" "bastion_template" {
  template = file("${path.module}/scripts/bastion.template.sh")

  vars = {
    user = var.oci_bastion.image_operating_system == "Canonical Ubuntu" ? "ubuntu" : "opc"
  }
  count = var.oci_bastion.create_bastion == true ? 1 : 0
}

data "template_file" "bastion_cloud_init_file" {
  template = file("${path.module}/cloudinit/bastion.template.yaml")

  vars = {
    bastion_sh_content = base64gzip(data.template_file.bastion_template[0].rendered)
    package_update     = var.oci_bastion.image_operating_system == "Canonical Ubuntu" ? var.oci_bastion.package_update : false
    package_upgrade    = var.oci_bastion.package_upgrade
    user               = var.oci_bastion.image_operating_system == "Canonical Ubuntu" ? "ubuntu" : "opc"
  }
  count = var.oci_bastion.create_bastion == true ? 1 : 0
}

# cloud init for bastion
data "template_cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "bastion.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.bastion_cloud_init_file[0].rendered
  }
  count = var.oci_bastion.create_bastion == true ? 1 : 0
}

data "template_file" "tesseract_template" {
  template = file("${path.module}/scripts/tesseract.template.sh")

  vars = {
    bastion_ip       = join(",", data.oci_core_vnic.bastion_vnic.*.public_ip_address)
    user             = var.oci_bastion.image_operating_system == "Canonical Ubuntu" ? "ubuntu" : "opc"
    private_key_path = var.oci_base_ssh_keys.ssh_private_key_path
  }
  count = var.oci_bastion.create_bastion == true ? 1 : 0
}

# Gets a list of VNIC attachments on the bastion instance
data "oci_core_vnic_attachments" "bastion_vnics_attachments" {
  availability_domain = element(var.oci_bastion_infra.ad_names, (var.oci_bastion_infra.availability_domains - 1))
  compartment_id      = var.oci_base_identity.compartment_ocid
  instance_id         = oci_core_instance.bastion[0].id
  count               = var.oci_bastion.create_bastion == true ? 1 : 0
}

# Gets the OCID of the first (default) VNIC on the bastion instance
data "oci_core_vnic" "bastion_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.bastion_vnics_attachments[0].vnic_attachments[0], "vnic_id")
  count   = var.oci_bastion.create_bastion == true ? 1 : 0
}

data "oci_core_instance" "bastion" {
  #Required
  instance_id = oci_core_instance.bastion[0].id
  count       = var.oci_bastion.create_bastion == true ? 1 : 0
}
