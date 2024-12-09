# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  istio_c1 = templatefile("${path.module}/resources/istio.template.yaml",
    {
      mesh_id          = var.istio_mesh_id
      cluster          = "c1"
      mesh_network     = "c1"
      pub_nsg_id       = one(element([module.c1[*].pub_lb_nsg_id], 0))
      int_lb_subnet_id = one(element([module.c1[*].int_lb_subnet_id], 0))
      int_nsg_id       = one(element([module.c1[*].int_lb_nsg_id], 0))
    }
  )

  istio_c2 = templatefile("${path.module}/resources/istio.template.yaml",
    {
      mesh_id          = var.istio_mesh_id
      cluster          = "c2"
      mesh_network     = "c2"
      pub_nsg_id       = one(element([module.c2[*].pub_lb_nsg_id], 0))
      int_lb_subnet_id = one(element([module.c2[*].int_lb_subnet_id], 0))
      int_nsg_id       = one(element([module.c2[*].int_lb_nsg_id], 0))
    }
  )
}

resource "null_resource" "istio" {
  depends_on = [module.c1, module.c2]

  connection {
    host        = local.operator_ip
    private_key = file(var.ssh_private_key_path)
    timeout     = "40m"
    type        = "ssh"
    user        = "opc"

    bastion_host        = local.bastion_ip
    bastion_user        = "opc"
    bastion_private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content     = local.istio_c1
    destination = "/home/opc/c1.yaml"
  }

  provisioner "file" {
    content     = local.istio_c2
    destination = "/home/opc/c2.yaml"
  }
}
