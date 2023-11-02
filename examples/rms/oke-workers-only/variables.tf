# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Identity

# Automatically populated by Resource Manager
variable "tenancy_ocid" { type = string }
variable "current_user_ocid" { type = string }
variable "compartment_ocid" { type = string }
variable "vcn_compartment_ocid" { type = string }
variable "region" { type = string }
variable "use_defined_tags" {
  default     = false
  description = "Add existing tags in the configured namespace to created resources when applicable."
  type        = bool
}

variable "tag_namespace" {
  default     = "oke"
  description = "Tag namespace containing standard tags for resources created by the module: [state_id, role, pool, cluster_autoscaler]."
  type        = string
}

variable "create_iam_autoscaler_policy" { default = false }
variable "create_iam_worker_policy" { default = false }
variable "autoscale" { default = false }

# Cluster

variable "cluster_id" {
  default = null
  type    = string
}
variable "cni_type" { default = "Flannel" }
variable "kubernetes_version" {
  default = "v1.27.2"
  type    = string
}

# Worker pools
variable "worker_pool_mode" {
  type = string
  validation {
    condition     = contains(["Node Pool", "Virtual Node Pool", "Instance", "Instance Pool", "Cluster Network"], var.worker_pool_mode)
    error_message = "Accepted values are Node Pool, Virtual Node Pool, Instance, Instance Pool, or Cluster Network"
  }
}
variable "worker_pool_size" {
  default = 1
  type    = number
}

# Workers: network

variable "vcn_id" {
  default = null
  type    = string
}
variable "assign_dns" { default = false }
variable "pod_nsg_id" { default = "" }
variable "pod_subnet_id" { default = "" }
variable "worker_nsg_id" { default = "" }
variable "worker_subnet_id" { type = string }
variable "kubeproxy_mode" { type = string }

# Workers: instance

variable "worker_block_volume_type" { type = string }
variable "worker_node_labels" {
  default = {}
  type    = map(string)
}
variable "worker_image_type" { type = string }
variable "worker_image_id" {
  default = null
  type    = string
}
variable "worker_image_os" {
  default = "Oracle Linux"
  type    = string
}
variable "worker_image_os_version" {
  default = "8"
  type    = string
}

variable "worker_pool_name" { type = string }

variable "worker_shape" { default = "VM.Standard.E4.Flex" }
variable "virtual_worker_shape" { default = "Pod.Standard.E4.Flex" }
variable "worker_ocpus" { default = 2 }
variable "worker_memory" { default = 16 }
variable "worker_boot_volume_size" { default = 50 }
variable "worker_pv_transit_encryption" { default = false }

variable "worker_disable_default_cloud_init" { default = false }
variable "worker_cloud_init_configure" { default = false }
variable "worker_cloud_init_content_type" {
  default = "text/x-shellscript"
  type    = string
}
variable "worker_cloud_init" {
  default = <<-EOT
  #!/usr/bin/env bash
  curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
  bash -x /var/run/oke-init.sh
  EOT
  type    = string
}

variable "worker_volume_kms_key_id" {
  default = null
  type    = string
}
variable "worker_volume_kms_vault_id" {
  default = null
  type    = string
}

variable "worker_image_platform_id" {
  default = null
  type    = string
}
variable "worker_image_custom_id" {
  default = null
  type    = string
}

variable "worker_tags" {
  default = {}
  type    = map(any)
}

variable "agent_are_all_plugins_disabled" {
  default = false
  type    = bool
}

variable "agent_is_management_disabled" {
  default = false
  type    = bool
}

variable "agent_is_monitoring_disabled" {
  default = false
  type    = bool
}

variable "agent_plugin_bastion" {
  default = false
  type    = bool
}

variable "agent_plugin_block_volume_management" {
  default = false
  type    = bool
}

variable "agent_plugin_compute_hpc_rdma_authentication" {
  default = false
  type    = bool
}

variable "agent_plugin_compute_hpc_rdma_auto_configuration" {
  default = false
  type    = bool
}

variable "agent_plugin_compute_instance_monitoring" {
  default = false
  type    = bool
}

variable "agent_plugin_compute_instance_run_command" {
  default = false
  type    = bool
}

variable "agent_plugin_compute_rdma_gpu_monitoring" {
  default = false
  type    = bool
}

variable "agent_plugin_custom_logs_monitoring" {
  default = false
  type    = bool
}

variable "agent_plugin_management_agent" {
  default = false
  type    = bool
}

variable "agent_plugin_oracle_autonomous_linux" {
  default = false
  type    = bool
}

variable "agent_plugin_os_management_service_agent" {
  default = false
  type    = bool
}
