# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {
  default = null
  type    = string
}

variable "current_user_ocid" {
  default = null
  type    = string
}

variable "compartment_ocid" {
  default = null
  type    = string
}

variable "region" {
  default = null
  type    = string
}

variable "create_iam_autoscaler_policy" {
  default = "Auto"
  type    = string
}

variable "create_iam_kms_policy" {
  default = "Auto"
  type    = string
}

variable "create_iam_operator_policy" {
  default = "Auto"
  type    = string
}

variable "create_iam_worker_policy" {
  default = "Auto"
  type    = string
}

variable "create_iam_resources" { default = false }
variable "create_iam_tag_namespace" { default = false }
variable "create_iam_defined_tags" { default = false }
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

variable "freeform_tags" {
  default = {
    cluster           = {}
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = {}
    operator          = {}
    vcn               = {}
  }
  type = any
}

variable "defined_tags" {
  default = {
    cluster           = {}
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = {}
    operator          = {}
    vcn               = {}
  }
  type = any
}
