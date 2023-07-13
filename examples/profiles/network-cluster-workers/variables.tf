# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "tenancy_id" { type = string }
variable "compartment_id" { type = string }
variable "region" { type = string }

variable "config_file_profile" {
  default = "DEFAULT"
  type    = string
}

variable "ssh_public_key_path" {
  default = null
  type    = string
}
