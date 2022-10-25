# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "primary_subnet_id" {
  description = "The subnet OCID used for instances"
  type        = string
}

variable "pod_subnet_id" {
  default     = ""
  description = "The subnet OCID used for pods when cni_type = npn"
  type        = string
}

variable "pod_nsg_ids" {
  default     = []
  description = "An additional list of network security group (NSG) OCIDs for pod security"
  type        = list(string)
}

variable "worker_nsg_ids" {
  default     = []
  description = "An additional list of network security group (NSG) OCIDs for node security"
  type        = list(string)
}

variable "ssh_public_key" {
  default = ""
  type    = string
}

variable "ssh_public_key_path" {
  default = ""
  type    = string
}