# Copyright (c) 2017, 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "install_calico" {
  connection {
    host        = var.operator_private_ip
    private_key = local.ssh_private_key
    timeout     = "40m"
    type        = "ssh"
    user        = var.operator_user

    bastion_host        = var.bastion_public_ip
    bastion_user        = var.bastion_user
    bastion_private_key = local.ssh_private_key
  }

  depends_on = [null_resource.install_k8stools_on_operator, null_resource.write_kubeconfig_on_operator]

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.calico_staging_dir}"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/resources/calico"
    destination = "${var.calico_staging_dir}/"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/split_yaml.awk"
    destination = "${var.calico_staging_dir}/split_yaml.awk"
  }

  provisioner "file" {
    content     = local.calico_env_template
    destination = "${var.calico_staging_dir}/calico_env.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/calico_install.sh"
    destination = "${var.calico_staging_dir}/calico_install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash ${var.calico_staging_dir}/calico_install.sh && rm -r ${var.calico_staging_dir}"
    ]
  }

  triggers = {
    calico_mode              = var.calico_mode
    calico_mtu               = var.calico_mtu
    calico_url               = var.calico_url
    calico_version           = var.calico_version
    calico_apiserver_enabled = var.calico_apiserver_enabled
    typha_enabled            = var.typha_enabled
    typha_replicas           = var.typha_replicas
  }

  count = local.post_provisioning_ops == true && var.install_calico == true ? 1 : 0
}
