# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "state_id" { type = string }
variable "tenancy_id" { type = string }
variable "cluster_id" { type = string }

# Tags
variable "create_tag_namespace" { type = bool }
variable "create_defined_tags" { type = bool }
variable "defined_tags" { type = map(string) }
variable "freeform_tags" { type = map(string) }
variable "tag_namespace" { type = string }
variable "use_defined_tags" { type = bool }

# Policy
variable "autoscaler_compartments" { type = list(string) }
variable "cluster_kms_key_id" { type = string }
variable "create_autoscaler_policy" { type = bool }
variable "create_kms_policy" { type = bool }
variable "create_operator_policy" { type = bool }
variable "create_worker_policy" { type = bool }
variable "operator_volume_kms_key_id" { type = string }
variable "worker_compartments" { type = list(string) }
variable "worker_volume_kms_key_id" { type = string }
