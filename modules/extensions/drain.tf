# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "drain_nodes" {
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

  provisioner "file" {
    content     = local.drain_list_template
    destination = "/home/opc/drainlist.py"
  }

  provisioner "file" {
    content     = local.drain_template
    destination = "/home/opc/drain.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -f \"$HOME/drainlist.py\" ]; then python3 \"$HOME/drainlist.py\"; rm -f \"$HOME/drainlist.py\";fi",
      "if [ -f \"$HOME/drain.sh\" ]; then bash \"$HOME/drain.sh\"; rm -f \"$HOME/drain.sh\";fi",
      "if [ -f \"$HOME/drainlist.txt\" ]; then cat \"$HOME/drainlist.txt\" >> \"$HOME/drained.txt\"; rm -f \"$HOME/drainlist.txt\";fi",
    ]
  }

  count = local.post_provisioning_ops == true && var.upgrade_nodepool == true ? 1 : 0
}
