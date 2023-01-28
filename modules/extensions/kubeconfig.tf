# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  generate_kubeconfig_template = templatefile("${path.module}/scripts/generate_kubeconfig.template.sh", {
    cluster-id = var.cluster_id
    region     = var.region
    }
  )

  set_credentials_template = templatefile("${path.module}/scripts/kubeconfig_set_credentials.template.sh", {
    cluster-id    = var.cluster_id
    cluster-id-11 = substr(var.cluster_id, (length(var.cluster_id) - 11), length(var.cluster_id))
    region        = var.region
    }
  )

  token_helper_template = templatefile("${path.module}/scripts/token_helper.template.sh", {
    cluster-id = var.cluster_id
    region     = var.region
    }
  )
}

resource "null_resource" "write_kubeconfig_on_operator" {
  connection {
    host        = var.operator_private_ip
    private_key = var.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = var.operator_user

    bastion_host        = var.bastion_public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
  }

  provisioner "file" {
    content     = local.generate_kubeconfig_template
    destination = "/home/${var.operator_user}/generate_kubeconfig.sh"
  }

  provisioner "file" {
    content     = local.token_helper_template
    destination = "/home/${var.operator_user}/token_helper.sh"
  }

  provisioner "file" {
    content     = local.set_credentials_template
    destination = "/home/${var.operator_user}/kubeconfig_set_credentials.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait &> /dev/null",
      "if [ -f \"$HOME/generate_kubeconfig.sh\" ]; then bash \"$HOME/generate_kubeconfig.sh\"; rm -f \"$HOME/generate_kubeconfig.sh\";fi",
      "mkdir $HOME/bin",
      "chmod +x $HOME/token_helper.sh",
      "mv $HOME/token_helper.sh $HOME/bin",
      "if [ -f \"$HOME/kubeconfig_set_credentials.sh\" ]; then bash \"$HOME/kubeconfig_set_credentials.sh\"; rm -f \"$HOME/kubeconfig_set_credentials.sh\";fi",
    ]
  }

  lifecycle {
    ignore_changes = all
  }
}
