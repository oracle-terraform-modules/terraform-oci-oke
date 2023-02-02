# Copyright 2017, 2023 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  bastion_public_ip                      = var.create_bastion_host == true ? module.bastion[0].bastion_public_ip : var.bastion_public_ip != "" ? var.bastion_public_ip : ""
  operator_private_ip                    = var.create_operator == true ? module.operator[0].operator_private_ip : var.operator_private_ip != "" ? var.operator_private_ip : ""
  operator_instance_principal_group_name = var.create_operator && var.enable_operator_instance_principal ? module.operator[0].operator_instance_principal_group_name : ""

  ig_route_id        = var.create_vcn == true ? module.vcn[0].ig_route_id : coalesce(var.ig_route_table_id, try(data.oci_core_route_tables.ig[0].route_tables[0].id, ""))
  nat_route_id       = var.create_vcn == true ? module.vcn[0].nat_route_id : coalesce(var.nat_route_table_id, try(data.oci_core_route_tables.nat[0].route_tables[0].id, ""))
  vcn_id             = var.create_vcn == true ? module.vcn[0].vcn_id : coalesce(var.vcn_id, try(data.oci_core_vcns.vcns[0].virtual_networks[0].id, ""))
  validate_drg_input = var.create_drg && (var.drg_id != null) ? tobool("[ERROR]: create_drg variable can not be true if drg_id is provided.]") : true

  worker_pool_subnet_id = coalesce(var.worker_pool_subnet_id, lookup(module.network.subnet_ids, "workers", ""))
}
