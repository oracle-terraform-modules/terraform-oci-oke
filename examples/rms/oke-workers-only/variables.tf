# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Identity

# Automatically populated by Resource Manager
variable "tenancy_ocid" { type = string }
variable "current_user_ocid" { type = string }
variable "compartment_ocid" { type = string }
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
  default = "v1.32.1"
  type    = string
}

# Worker pools
variable "worker_pool_mode" {
  default = "Instances"
  type    = string
  validation {
    condition     = contains(["Node Pool", "Instances", "Instance Pool", "Cluster Network"], var.worker_pool_mode)
    error_message = "Accepted values are Node Pool, Instances, Instance Pool, or Cluster Network"
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
variable "assign_dns" { default = true }
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
variable "worker_ocpus" { default = 2 }
variable "worker_memory" { default = 16 }
variable "worker_boot_volume_size" { default = 50 }
variable "worker_pv_transit_encryption" { default = false }

variable "worker_cloud_init_configure" { type = bool }
variable "worker_cloud_init_oke" {
  default = <<-EOT
  #!/usr/bin/env bash
  curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh
  bash /etc/oke/oke-install.sh
  EOT
  type    = string
}
variable "worker_cloud_init_byon" {
  default = <<-EOT
  #!/usr/bin/env bash
  #apiserver_host="10.0.0.1"
  #ca_base64="LS0tLS1...LS0tCg==" # kubectl config view --raw -o json | jq -rcM '.clusters[0].cluster["certificate-authority-data"]'
  bash /etc/oke/oke-install.sh --apiserver-endpoint "$\{apiserver_host}" --kubelet-ca-cert "$\{ca_base64}"
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
