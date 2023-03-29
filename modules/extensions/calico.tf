# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  calico_env_template = templatefile("${path.module}/scripts/calico_env.sh",
    {
      mode                 = var.calico_mode
      version              = var.calico_version
      cni_type             = var.cni_type
      mtu                  = var.calico_mtu
      pod_cidr             = var.pods_cidr
      url                  = var.calico_url
      apiserver_enabled    = var.calico_apiserver_install
      calico_typha_enabled = var.calico_typha_install || var.expected_node_count > 50

      # Use provided value if set, otherwise use 1 replica for every 50 nodes with a min of 1 if enabled, and max of 20 replicas
      calico_typha_replicas = (var.calico_typha_replicas > 0) ? var.calico_typha_replicas : max(min(20, floor(var.expected_node_count / 50)), var.calico_typha_install ? 1 : 0)
    }
  )
}

resource "null_resource" "calico_enabled" {
  count = alltrue([var.calico_install, var.expected_node_count > 0]) ? 1 : 0
  triggers = {
    calico_mode              = var.calico_mode
    calico_mtu               = var.calico_mtu
    calico_url               = var.calico_url
    calico_version           = var.calico_version
    calico_apiserver_enabled = var.calico_apiserver_install
    calico_typha_enabled     = var.calico_typha_install
    calico_typha_replicas    = var.calico_typha_replicas
  }

  connection {
    bastion_host        = var.bastion_host
    bastion_user        = var.bastion_user
    bastion_private_key = var.ssh_private_key
    host                = var.operator_host
    user                = var.operator_user
    private_key         = var.ssh_private_key
    timeout             = "40m"
    type                = "ssh"
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p ${var.calico_staging_dir}"]
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
    inline = ["bash ${var.calico_staging_dir}/calico_install.sh && rm -r ${var.calico_staging_dir}"]
  }
}
