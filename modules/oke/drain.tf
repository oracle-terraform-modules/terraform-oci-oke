# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "template_file" "drain" {
  template = file("${path.module}/scripts/drain.template.sh")

  count = var.nodepool_drain == true ? 1 : 0
}

data "template_file" "drainlist" {
  template = file("${path.module}/scripts/drainlist.py")

   vars = {
     cluster_id       = oci_containerengine_cluster.k8s_cluster.id
     compartment_id   = var.compartment_id
     region           = var.region
     pools_to_drain   = var.label_prefix == "none" ? trim(join(",", formatlist("'%s'", var.node_pools_to_drain)), "'") : trim(join(",", formatlist("'%s-%s'", var.label_prefix, var.node_pools_to_drain)), "'")    
   }  

  count = var.nodepool_drain == true ? 1 : 0
}

resource null_resource "drain_nodes" {
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
    content     = data.template_file.drainlist[0].rendered
    destination = "~/drainlist.py"
  }

  provisioner "file" {
    content     = data.template_file.drain[0].rendered
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

  count = var.oke_operator.bastion_enabled == true && var.oke_operator.operator_enabled == true && var.nodepool_drain == true ? 1 : 0
}
