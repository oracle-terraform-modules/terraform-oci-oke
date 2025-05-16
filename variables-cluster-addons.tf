# Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "cluster_addons" {
  description = "Map with cluster addons that should be enabled.  See <a href=https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengconfiguringclusteraddons-configurationarguments.htm#contengconfiguringclusteraddons-supportedarguments>ClusterAddon documentation</a> for the supported configuration of each addon."
  type        = any
  default     = {}
}

variable "cluster_addons_to_remove" {
  description = "Map with cluster addons not created by Terraform that should be removed. This operation is performed using oci-cli and requires the operator host to be deployed."
  type        = any
  default     = {}
}