# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id    = oci_containerengine_cluster.k8s_cluster.id
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
  content    = data.oci_containerengine_cluster_kube_config.kube_config.content
  depends_on = [null_resource.create_local_kubeconfig, oci_containerengine_cluster.k8s_cluster]
  filename   = "${path.root}/generated/kubeconfig"
}

data "template_file" "install_kubectl" {
  template = file("${path.module}/scripts/install_kubectl.template.sh")
}

resource "null_resource" "install_kubectl_operator" {
  connection {
    host        = var.oke_operator.operator_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_operator.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  provisioner "file" {
    content     = data.template_file.install_kubectl.rendered
    destination = "~/install_kubectl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/install_kubectl.sh",
      "bash $HOME/install_kubectl.sh",
      "rm -f $HOME/install_kubectl.sh"
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true && var.reuse == false ? 1 : 0
}

# wait for 1. operator being ready 2. kubectl is installed (the script will create the .kube directory)
resource null_resource "wait_for_operator" {
  connection {
    host        = var.oke_operator.operator_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_operator.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  depends_on = [null_resource.install_kubectl_operator]

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /home/opc/operator.finish ]; do sleep 10; done",
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true ? 1 : 0
}

data "template_file" "generate_kubeconfig" {
  template = file("${path.module}/scripts/generate_kubeconfig.template.sh")

  vars = {
    cluster-id = oci_containerengine_cluster.k8s_cluster.id
    region     = var.region
    cluster_name = var.oke_cluster.cluster_name
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true ? 1 : 0
}

resource "null_resource" "write_kubeconfig_on_operator" {
  connection {
    host        = var.oke_operator.operator_private_ip
    private_key = file(var.oke_ssh_keys.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.oke_operator.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.oke_ssh_keys.ssh_private_key_path)
  }

  depends_on = [oci_containerengine_cluster.k8s_cluster, null_resource.wait_for_operator]

  provisioner "file" {
    content     = data.template_file.generate_kubeconfig[0].rendered
    destination = "~/generate_kubeconfig.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/generate_kubeconfig.sh",
      "$HOME/generate_kubeconfig.sh",
      "rm -f $HOME/generate_kubeconfig.sh"
    ]
  }

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true ? 1 : 0
}
