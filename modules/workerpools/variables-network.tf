# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "assign_dns" {
  default     = true
  description = "Whether to assign DNS records to created instances"
  type        = bool
}

variable "assign_public_ip" {
  default     = false
  description = "Whether to assign public IP addresses to worker nodes"
  type        = bool
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
