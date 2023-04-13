# Copyright (c) 2017, 2022 Oracle Corporation and/or its affiliates.

# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# for reuse 

output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = module.oke.cluster_id
}

output "nodepool_ids" {
  description = "Map of Nodepool names and IDs"
  value       = module.oke.nodepool_ids
}

output "ig_route_id" {
  description = "id of route table to vcn internet gateway"
  value       = local.ig_route_id
}

output "nat_route_id" {
  description = "id of route table to nat gateway attached to vcn"
  value       = local.nat_route_id
}

# Deprecated
output "int_lb_nsg" {
  description = "id of default NSG that can be associated with the internal load balancer"
  value       = module.network.int_lb
}

output "nsg_ids" {
  description = "map of NSG ids (cp, worker, int_lb, pub_lb, pod) used by OKE."
  value       = module.network.nsg_ids
}

# Deprecated
output "pub_lb_nsg" {
  description = "id of default NSG that can be associated with the internal load balancer"
  value       = module.network.pub_lb
}

output "subnet_ids" {
  description = "map of subnet ids (cp, worker, int_lb, pub_lb, pod) used by OKE."
  value       = module.network.subnet_ids
}

output "vcn_id" {
  description = "id of vcn where oke is created. use this vcn id to add additional resources"
  value       = local.vcn_id
}

output "drg_id" {
  description = "ID of DRG. use this DRG id to add additional resources"
  value       = var.create_drg || var.drg_id != null ? module.drg[0].drg_id : null
}

output "rpcs_ids" {
  description = "IDs of remote peering connections"
  value = (var.create_drg || var.drg_id != null) && length(var.remote_peering_connections) > 0  ? { for k, v in module.drg[0].rpc_all_attributes : k => v.id } : null 

}

# convenient output

output "bastion_public_ip" {
  description = "public ip address of bastion host"
  value       = local.bastion_public_ip
}

output "operator_private_ip" {
  description = "private ip address of operator host"
  value       = local.operator_private_ip
}

output "ssh_to_operator" {
  description = "convenient command to ssh to the operator host"
  value       = "ssh${local.ssh_key_arg} -o ProxyCommand='ssh ${local.ssh_key_arg} -W %h:%p ${var.bastion_user}@${local.bastion_public_ip}' ${var.operator_user}@${local.operator_private_ip}"
}

output "ssh_to_bastion" {
  description = "convenient command to ssh to the bastion host"
  value       = "ssh${local.ssh_key_arg} ${var.bastion_user}@${local.bastion_public_ip}"
}

output "bastion_service_instance_id" {
  value = var.create_bastion_service == true ? module.bastionsvc[0].bastion_id : null
}

output "fss_id" {
  value = var.create_fss == true ? module.storage[0].fss_id : null
}

output "cluster_endpoints" {
  description = "Endpoints for the Kubernetes cluster"
  value       = module.oke.endpoints
}

output "autoscaling_nodepools" {
  value = module.oke.autoscaling_nodepools
}
