# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Terraform
output "state_id" { value = module.oke.state_id }

# Network
output "worker_subnet_id" { value = var.worker_subnet_id }
output "worker_nsg_id" { value = var.worker_nsg_id }

# Identity
output "dynamic_group_ids" { value = module.oke.dynamic_group_ids }
output "policy_statements" { value = module.oke.policy_statements }
output "create_iam_autoscaler_policy" { value = var.create_iam_autoscaler_policy }
output "create_iam_worker_policy" { value = var.create_iam_worker_policy }

# Cluster
output "cluster_id" { value = var.cluster_id }
output "apiserver_private_host" { value = module.oke.apiserver_private_host }

# Workers
output "worker_pool_name" { value = var.worker_pool_name }
output "worker_pool_mode" { value = var.worker_pool_mode }
output "worker_shape" { value = var.worker_shape }
output "worker_pool_size" { value = var.worker_pool_size }
output "worker_image_id" { value = local.worker_image_id }
output "autoscale" { value = var.autoscale }

output "worker_pool_ids" {
  value = concat(
    values(coalesce(module.oke.worker_pool_ids, {})),
    values(coalesce(module.oke.worker_instance_ids, {})),
  )
}
