# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "install_calico" {
  template = "${file("${path.module}/scripts/install_calico.template.sh")}"

  vars = {
    calico_version  = "${var.calico_version}"
    number_of_nodes = "(${var.nodepool_topology} * ${var.node_pools} * ${var.node_pool_quantity_per_subnet})"
    user_ocid       = "${var.user_ocid}"
  }

  count = "${var.install_calico == true   ? 1 : 0}"
}

resource null_resource "write_install_calico" {
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_calico.rendered}"
    destination = "~/install_calico.sh"
  }

  count = "${(var.availability_domains["bastion"] == 1 && var.install_calico == true)   ? 1 : 0}"
}

resource null_resource "install_calico" {
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  depends_on = ["null_resource.install_kubectl_bastion", "null_resource.write_kubeconfig_bastion"]

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_calico.sh",
      "~/install_calico.sh",
    ]
  }

  count = "${(var.availability_domains["bastion"] == 1 && var.install_calico == true)   ? 1 : 0}"
}
