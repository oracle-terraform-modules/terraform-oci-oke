# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  bastion_public_ip                      = var.create_bastion_host == true ? module.bastion[0].bastion_public_ip : ""
  operator_private_ip                    = var.create_operator == true ? module.operator[0].operator_private_ip : ""
  operator_instance_principal_group_name = var.create_operator == true ? module.operator[0].operator_instance_principal_group_name : ""
}
