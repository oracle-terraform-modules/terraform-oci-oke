# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "bastion_public_ip" {
  value = "${module.base.bastion_public_ip}"
}

output "cluster_endpoint" {
  value = "${module.oke.cluster_endpoint}"
}

output "ssh_to_bastion" {
  value = "${module.base.ssh_to_bastion}"
}

output "kubeconfig_env" {
  value = "export KUBECONFIG=${var.config_output_path}/kubeconfig_${var.cluster_name}"
}

output "kubeconfig_file" {
  value = "${var.config_output_path}/kubeconfig_${var.cluster_name}"
}

output "ocirtoken" {
  value = "${module.auth.ocirtoken}"
  sensitive = true
}
