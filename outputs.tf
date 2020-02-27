# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "bastion_public_ip" {
  description = "public ip address of bastion host"
  value       = module.base.bastion_public_ip
}

output "admin_private_ip" {
  description = "private ip address of admin host"
  value       = module.base.admin_private_ip
}

output "ssh_to_admin" {
  description = "convenient command to ssh to the admin host"
  value       = module.base.ssh_to_admin
}

output "ssh_to_bastion" {
  description = "convenient command to ssh to the bastion host"
  value       = module.base.ssh_to_bastion
}

output "kubeconfig" {
  description = "convenient command to set KUBECONFIG environment variable before running kubectl locally"
  value       = "export KUBECONFIG=generated/kubeconfig"
}

output "ocirtoken" {
  description = "authentication token for ocir"
  sensitive   = true
  value       = module.auth.ocirtoken
}
