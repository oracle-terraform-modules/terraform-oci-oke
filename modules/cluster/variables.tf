# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "state_id" { type = string }

# Cluster
variable "cluster_kms_key_id" { type = string }
variable "cluster_name" { type = string }
variable "cluster_type" { type = string }
variable "cni_type" { type = string }
variable "enable_ipv6" { type = bool }
variable "control_plane_is_public" { type = bool }
variable "control_plane_nsg_ids" { type = set(string) }
variable "assign_public_ip_to_control_plane" { type = bool }
variable "control_plane_subnet_id" { type = string }
variable "image_signing_keys" { type = set(string) }
variable "kubernetes_version" { type = string }
variable "pods_cidr" { type = string }
variable "service_lb_subnet_id" { type = string }
variable "services_cidr" { type = string }
variable "tag_namespace" { type = string }
variable "use_defined_tags" { type = string }
variable "use_signed_images" { type = bool }
variable "vcn_id" { type = string }

# Tagging
variable "cluster_defined_tags" { type = map(string) }
variable "cluster_freeform_tags" { type = map(string) }
variable "persistent_volume_defined_tags" { type = map(string) }
variable "persistent_volume_freeform_tags" { type = map(string) }
variable "service_lb_defined_tags" { type = map(string) }
variable "service_lb_freeform_tags" { type = map(string) }

# OIDC
variable "oidc_discovery_enabled" { type = bool }
variable "oidc_token_auth_enabled" { type = bool }
variable "oidc_token_authentication_config" { type = any }