# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id    = "${oci_containerengine_cluster.k8s_cluster.id}"
  expiration    = "${var.cluster_kube_config_expiration}"
  token_version = "${var.cluster_kube_config_token_version}"
}

resource "null_resource" "create_local_kubeconfig" {
  provisioner "local-exec" {
    command = "rm -rf generated"
  }

  provisioner "local-exec" {
    command = "mkdir generated"
  }

  provisioner "local-exec" {
    command = "touch generated/kubeconfig"
  }
}

resource "local_file" "kube_config_file" {
  content    = "${data.oci_containerengine_cluster_kube_config.kube_config.content}"
  depends_on = ["null_resource.create_local_kubeconfig", "oci_containerengine_cluster.k8s_cluster"]
  filename   = "${path.root}/generated/kubeconfig"
}

data "template_file" "install_kubectl" {
  template = "${file("${path.module}/scripts/install_kubectl.template.sh")}"

  vars {
    package_manager = "${var.preferred_bastion_image == "ubuntu"   ? "snap" : "yum"}"
  }
}

resource "null_resource" "write_install_kubectl_bastion" {
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "file" {
    content     = "${data.template_file.install_kubectl.rendered}"
    destination = "~/install_kubectl.sh"
  }

  count = "${var.availability_domains["bastion"] == 1   ? 1 : 0}"
}

resource "null_resource" "install_kubectl_bastion" {
  depends_on = ["null_resource.write_install_kubectl_bastion"]

  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/install_kubectl.sh",
      "~/install_kubectl.sh",
    ]
  }

  count = "${var.availability_domains["bastion"] == 1   ? 1 : 0}"
}

resource "null_resource" "write_kubeconfig_bastion" {
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  depends_on = ["local_file.kube_config_file"]

  provisioner "file" {
    source      = "generated/kubeconfig"
    destination = "~/.kube/config"
  }

  count = "${var.availability_domains["bastion"] == 1   ? 1 : 0}"
}
