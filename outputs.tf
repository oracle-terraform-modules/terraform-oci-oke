# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "bastion_public_ip" {
  value = module.base.bastion_public_ip
}

output "admin_private_ip" {
  value = module.base.admin_private_ip
}

output "ssh_to_admin" {
  value = module.base.ssh_to_admin
}

output "ssh_to_bastion" {
  value = module.base.ssh_to_bastion
}

output "kubeconfig" {
  value = "export KUBECONFIG=generated/kubeconfig"
}

output "ocirtoken" {
  value     = module.auth.ocirtoken
  sensitive = true
}
