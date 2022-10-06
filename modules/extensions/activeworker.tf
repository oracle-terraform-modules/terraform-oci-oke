# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "check_worker_active" {
  triggers = {
    node_pools = length(data.oci_containerengine_node_pools.all_node_pools.node_pools)
  }

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

  depends_on = [null_resource.write_kubeconfig_on_operator]

  provisioner "file" {
    content     = local.check_active_worker_template
    destination = "/home/opc/check_active_worker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/check_active_worker.sh\" ]; then bash \"$HOME/check_active_worker.sh\"; rm -f \"$HOME/check_active_worker.sh\";fi",
    ]
  }

  count = local.post_provisioning_ops == true && var.check_node_active != "none" ? 1 : 0
}
