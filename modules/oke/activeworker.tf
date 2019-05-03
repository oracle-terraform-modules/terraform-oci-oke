# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "check_worker_node_status" {
  template = "${file("${path.module}/scripts/is_worker_active.py")}"

  vars {
    cluster_id     = "${oci_containerengine_cluster.k8s_cluster.id}"
    compartment_id = "${var.compartment_ocid}"
    region         = "${var.region}"
  }

  count = "${(var.create_bastion == true && var.enable_instance_principal == true)   ? 1 : 0}"
}

resource null_resource "is_worker_active" {
  # depends_on = ["null_resource.write_check_worker_script", "oci_containerengine_cluster.k8s_cluster"]
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.image_operating_system == "Canonical Ubuntu"   ? "ubuntu" : "opc"}"
  }

  depends_on = ["oci_containerengine_cluster.k8s_cluster"]

  provisioner "file" {
    content     = "${data.template_file.check_worker_node_status.rendered}"
    destination = "~/is_worker_active.py"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x $HOME/is_worker_active.py",
      "while [ ! -f $HOME/node.active ]; do $HOME/is_worker_active.py; sleep 10; done",
    ]
  }

  count = "${(var.create_bastion == true  && var.enable_instance_principal == true) ? 1 : 0}"
}
