# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "check_worker_node_status" {
  template = "${file("${path.module}/scripts/is_worker_active.py")}"

  vars {
    cluster_id     = "${oci_containerengine_cluster.k8s_cluster.id}"
    compartment_id = "${var.compartment_ocid}"
    region         = "${var.region}"
  }
}

resource null_resource "write_check_worker_script" {
  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "file" {
    content     = "${data.template_file.check_worker_node_status.rendered}"
    destination = "/home/opc/is_worker_active.py"
  }

  count = "${var.availability_domains["bastion"] == 1   ? 1 : 0}"
}

resource null_resource "is_worker_active" {
  depends_on = ["null_resource.write_check_worker_script", "oci_containerengine_cluster.k8s_cluster"]

  connection {
    host        = "${var.bastion_public_ip}"
    private_key = "${file(var.ssh_private_key_path)}"
    timeout     = "40m"
    type        = "ssh"
    user        = "${var.preferred_bastion_image == "ubuntu"   ? "ubuntu" : "opc"}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/opc/is_worker_active.py",
      "while [ ! -f /home/opc/node.active ]; do /home/opc/is_worker_active.py; sleep 10; done",
    ]
  }

  count = "${var.availability_domains["bastion"] == 1  ? 1 : 0}"
}
