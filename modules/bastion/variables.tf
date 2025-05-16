# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "state_id" { type = string }

# Bastion
variable "await_cloudinit" { type = string }
variable "assign_dns" { type = bool }
variable "availability_domain" { type = string }
variable "bastion_image_os_version" { type = string }
variable "image_id" { type = string }
variable "is_public" { type = bool }
variable "nsg_ids" { type = list(string) }
variable "shape" { type = map(any) }
variable "ssh_private_key" {
  type      = string
  sensitive = true
}
variable "ssh_public_key" { type = string }
variable "subnet_id" { type = string }
variable "timezone" { type = string }
variable "upgrade" { type = bool }
variable "user" { type = string }

# Tags
variable "defined_tags" { type = map(string) }
variable "freeform_tags" { type = map(string) }
variable "tag_namespace" { type = string }
variable "use_defined_tags" { type = bool }