# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Terraform
output "state_id" { value = module.oke.state_id }

# Identity
output "dynamic_group_ids" { value = module.oke.dynamic_group_ids }
output "policy_statements" { value = module.oke.policy_statements }

# Network
output "vcn_id" { value = module.oke.vcn_id }
output "drg_id" { value = module.oke.drg_id }
output "ig_route_table_id" { value = module.oke.ig_route_table_id }
output "nat_route_table_id" { value = module.oke.nat_route_table_id }

# NSGs
output "nsg_ids" { value = module.oke.nsg_ids }

# Bastion
output "bastion_id" { value = module.oke.bastion_id }
output "bastion_public_ip" { value = module.oke.bastion_public_ip }
output "bastion_subnet_id" { value = module.oke.bastion_subnet_id }
output "bastion_nsg_id" { value = coalesce(var.bastion_nsg_id, "none") != "none" ? var.bastion_nsg_id : module.oke.bastion_nsg_id }
output "bastion_ssh_command" { value = module.oke.ssh_to_bastion }
output "bastion_ssh_secret_id" { value = var.ssh_kms_secret_id }

# Operator
output "operator_id" { value = module.oke.operator_id }
output "operator_private_ip" { value = module.oke.operator_private_ip }
output "operator_subnet_id" { value = module.oke.operator_subnet_id }
output "operator_nsg_id" { value = coalesce(var.operator_nsg_id, "none") != "none" ? var.operator_nsg_id : module.oke.operator_nsg_id }
output "operator_ssh_command" { value = module.oke.ssh_to_operator }
output "operator_ssh_secret_id" { value = var.ssh_kms_secret_id }

# Cluster
output "cluster_id" { value = module.oke.cluster_id }
output "cluster_endpoints" { value = module.oke.cluster_endpoints }
output "cluster_kubeconfig" { value = module.oke.cluster_kubeconfig }
output "cluster_ca_cert" { value = module.oke.cluster_ca_cert }
output "control_plane_subnet_id" { value = module.oke.control_plane_subnet_id }
output "int_lb_subnet_id" { value = module.oke.int_lb_subnet_id }
output "pub_lb_subnet_id" { value = module.oke.pub_lb_subnet_id }
output "control_plane_nsg_id" { value = coalesce(var.control_plane_nsg_id, "none") != "none" ? var.control_plane_nsg_id : module.oke.control_plane_nsg_id }

output "bastion_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "bastion", null) }
output "operator_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "operator", null) }
output "control_plane_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "cp", null) }
output "worker_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "workers", null) }
output "pod_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "pods", null) }
output "int_lb_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "int_lb", null) }
output "pub_lb_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "pub_lb", null) }
output "fss_subnet_cidr" { value = lookup(module.oke.subnet_cidrs, "fss", null) }

output "worker_subnet_id" { value = module.oke.worker_subnet_id }
output "worker_nsg_id" { value = coalesce(var.worker_nsg_id, "none") != "none" ? var.worker_nsg_id : module.oke.worker_nsg_id }
output "pod_subnet_id" { value = module.oke.pod_subnet_id }
output "pod_nsg_id" { value = coalesce(var.pod_nsg_id, "none") != "none" ? var.pod_nsg_id : module.oke.pod_nsg_id }
output "fss_id" { value = module.oke.fss_id }
output "fss_subnet_id" { value = module.oke.fss_subnet_id }
output "fss_nsg_id" { value = coalesce(var.fss_nsg_id, "none") != "none" ? var.fss_nsg_id : module.oke.fss_nsg_id }
