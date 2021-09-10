# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "null_resource" "drain_nodes" {
  connection {
    host        = var.operator_private_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = var.bastion_public_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content = local.drain_list_template
    destination = "~/drainlist.py"
  }

  provisioner "file" {
    content = local.drain_template
    destination = "~/drain.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "python3 drainlist.py",
      "chmod +x $HOME/drain.sh",
      "$HOME/drain.sh",
      "cat drainlist.txt >> drained.txt",
      "rm -f drainlist.txt"
    ]
  }

  count = local.post_provisioning_ops == true && var.nodepool_drain == true ? 1 : 0
}
