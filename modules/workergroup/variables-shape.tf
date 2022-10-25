# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "boot_volume_size" {
  default     = 50
  description = "Default size in GB for the boot volume of created worker nodes"
  type        = number
}

variable "memory" {
  description = "Default memory in GB for flex shapes"
  type        = number
  default     = 16
}

variable "ocpus" {
  description = "Default ocpus for flex shapes"
  type        = number
  default     = 1
}

variable "shape" {
  default     = "VM.Standard.E4.Flex"
  description = "Default shape for instance pools"
  type        = string
}

variable "size" {
  default     = 0
  description = "Default number of desired nodes for created worker groups"
  type        = number
}