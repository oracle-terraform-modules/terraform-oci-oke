# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "cloudinit" {
  type        = string
  description = "Base64-encoded cloud init script to run on instance boot"
  default     = ""
}

variable "image_id" {
  default     = ""
  description = "Default image OCID for worker groups when unspecified and image_type = custom"
  type        = string
}

variable "image_type" {
  default     = "custom"
  description = "Whether to use a Platform, OKE or custom image. When custom is set, the image_id must be specified."
  type        = string
  validation {
    condition     = contains(["custom", "oke", "platform"], var.image_type)
    error_message = "Accepted values are custom, oke, platform"
  }
}

variable "os" {
  default     = "Oracle Linux"
  description = "The name of image to use."
  type        = string
}

variable "os_version" {
  default     = "7.9"
  description = "The version of operating system to use for the worker nodes."
  type        = string
}