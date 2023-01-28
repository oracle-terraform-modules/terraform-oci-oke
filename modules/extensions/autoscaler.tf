# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  oke_autoscaling_configs = { # Repeatable --nodes argument values with `oci-oke` cloud provider for node pools
    for k, v in var.autoscaling_groups : k => "${lookup(v, "size_min", v.size)}:${lookup(v, "size_max", v.size)}:${v.id}"
    if v.mode == "node-pool"
  }
  oke_ca_yaml_template = templatefile("${path.module}/resources/clusterautoscaler.yaml.tpl", {
    region              = var.region
    cloud_provider      = "oci-oke"
    autoscaling_configs = local.oke_autoscaling_configs
  })
  oke_ca_yaml_remote_path = "/home/${var.operator_user}/cluster-autoscaler_oke.yaml"
  oke_ca_yaml_checksum    = md5(local.oke_ca_yaml_template)
}

resource "null_resource" "deploy_cluster_autoscaler" {
  count = var.deploy_cluster_autoscaler ? 1 : 0

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
    content     = local.oke_ca_yaml_template
    destination = local.oke_ca_yaml_remote_path
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f \"${local.oke_ca_yaml_remote_path}\"",
    ]
  }

  depends_on = [
    null_resource.write_kubeconfig_on_operator
  ]

  triggers = merge(local.oke_autoscaling_configs, {
    deployment_checksum = local.oke_ca_yaml_checksum,
  })
}
