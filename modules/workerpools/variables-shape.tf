# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "boot_volume_size" {
  default     = 50
  description = "Default size in GB for the boot volume of created worker nodes"
  type        = number
}

variable "memory" {
  description = "Default memory in GB for flex shapes"
  default     = 16
  type        = number
}

variable "ocpus" {
  description = "Default ocpus for flex shapes"
  default     = 1
  type        = number
}

variable "shape" {
  default     = "VM.Standard.E4.Flex"
  description = "Default shape for instance pools"
  type        = string
}
