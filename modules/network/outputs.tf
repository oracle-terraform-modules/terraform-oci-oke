# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "subnet_ids" {
  value = {
    "cp"      = join(",", oci_core_subnet.cp[*].id)
    "workers" = join(",", oci_core_subnet.workers[*].id)
    "int_lb"  = join(",", oci_core_subnet.int_lb[*].id)
    "pub_lb"  = join(",", oci_core_subnet.pub_lb[*].id)
  }
}

output "control_plane_nsg_id" {
  value = oci_core_network_security_group.cp.id
}

output "int_lb" {
  value = var.load_balancers == "internal" || var.load_balancers == "both" ? oci_core_network_security_group.int_lb[0].id : ""
}

output "pub_lb" {
  value = var.load_balancers == "public" || var.load_balancers == "both" ? oci_core_network_security_group.pub_lb[0].id :""
}

output "worker_nsg_id" {
  value = oci_core_network_security_group.workers.id
}

