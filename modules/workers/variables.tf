# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "state_id" { type = string }
variable "tenancy_id" { type = string }

# Tags
variable "defined_tags" { type = map(string) }
variable "freeform_tags" { type = map(string) }
variable "tag_namespace" { type = string }
variable "use_defined_tags" { type = bool }

# Cluster
variable "apiserver_private_host" { type = string }
variable "cluster_ca_cert" { type = string }
variable "cluster_dns" { type = string }
variable "cluster_id" { type = string }
variable "kubernetes_version" { type = string }

# Network
variable "assign_dns" { type = bool }
variable "assign_public_ip" { type = bool }
variable "cni_type" { type = string }
variable "pod_nsg_ids" { type = list(string) }
variable "pod_subnet_id" { type = string }
variable "worker_nsg_ids" { type = list(string) }
variable "worker_subnet_id" { type = string }

# Worker pools
variable "worker_pool_mode" { type = string }
variable "worker_pool_size" { type = number }
variable "worker_pools" { type = any }

# Workers: instance
variable "ad_numbers_to_names" { type = map(string) }
variable "ad_numbers" { type = list(number) }
variable "block_volume_type" { type = string }
variable "cloud_init" { type = list(map(string)) }
variable "image_id" { type = string }
variable "image_ids" { type = map(any) }
variable "image_os_version" { type = string }
variable "image_os" { type = string }
variable "image_type" { type = string }
variable "kubeproxy_mode" { type = string }
variable "max_pods_per_node" { type = number }
variable "node_labels" { type = map(string) }
variable "pv_transit_encryption" { type = bool }
variable "shape" { type = map(any) }
variable "ssh_public_key" { type = string }
variable "timezone" { type = string }
variable "volume_kms_key_id" { type = string }

# FSS
variable "create_fss" { type = bool }
variable "fss_availability_domain" { type = string }
variable "fss_max_fs_stat_bytes" { type = string }
variable "fss_max_fs_stat_files" { type = string }
variable "fss_mount_path" { type = string }
variable "fss_nsg_ids" { type = list(string) }
variable "fss_subnet_id" { type = string }
