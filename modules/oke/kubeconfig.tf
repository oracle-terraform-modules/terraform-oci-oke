# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_containerengine_cluster_kube_config" "kube_config" {
  cluster_id = oci_containerengine_cluster.k8s_cluster.id
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
  content         = data.oci_containerengine_cluster_kube_config.kube_config.content
  depends_on      = [null_resource.create_local_kubeconfig, oci_containerengine_cluster.k8s_cluster]
  filename        = "${path.root}/generated/kubeconfig"
  file_permission = "0600"
}

data "template_file" "generate_kubeconfig" {
  template = file("${path.module}/scripts/generate_kubeconfig.template.sh")

  vars = {
    cluster-id = oci_containerengine_cluster.k8s_cluster.id
    region     = var.region
  }

  count = local.post_provisioning_ops == true ? 1 : 0
}

data "template_file" "token_helper" {
  template = file("${path.module}/scripts/token_helper.template.sh")

  vars = {
    cluster-id = oci_containerengine_cluster.k8s_cluster.id
    region     = var.region
  }

  count = local.post_provisioning_ops == true ? 1 : 0
}

data "template_file" "set_credentials" {
  template = file("${path.module}/scripts/kubeconfig_set_credentials.template.sh")

  vars = {
    cluster-id    = oci_containerengine_cluster.k8s_cluster.id
    cluster-id-11 = substr(oci_containerengine_cluster.k8s_cluster.id, (length(oci_containerengine_cluster.k8s_cluster.id) - 11), length(oci_containerengine_cluster.k8s_cluster.id))
    region        = var.region
  }

  count = local.post_provisioning_ops == true ? 1 : 0
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

  depends_on = [oci_containerengine_cluster.k8s_cluster, null_resource.install_kubectl_operator]

  provisioner "file" {
    content     = data.template_file.generate_kubeconfig[0].rendered
    destination = "~/generate_kubeconfig.sh"
  }

  provisioner "file" {
    content     = data.template_file.token_helper[0].rendered
    destination = "~/token_helper.sh"
  }

  provisioner "file" {
    content     = data.template_file.set_credentials[0].rendered
    destination = "~/kubeconfig_set_credentials.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/generate_kubeconfig.sh",
      "$HOME/generate_kubeconfig.sh",
      "chmod +x $HOME/token_helper.sh",
      "sudo mv $HOME/token_helper.sh /usr/local/bin",
      "chmod +x $HOME/kubeconfig_set_credentials.sh",
      "$HOME/kubeconfig_set_credentials.sh",
      "rm -f $HOME/generate_kubeconfig.sh",
      "rm -f $HOME/kubeconfig_set_credentials.sh"
    ]
  }

  count = local.post_provisioning_ops == true ? 1 : 0
}
