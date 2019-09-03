# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# general

variable "oci_base_identity" {
  type = object({
    api_fingerprint      = string
    api_private_key_path = string
    compartment_ocid     = string
    compartment_name     = string
    tenancy_ocid         = string
    user_ocid            = string
  })
}

variable "oci_bastion_general" {
  type = object({
    label_prefix = string
    home_region  = string
    region       = string
  })
}

# ssh

variable "oci_base_ssh_keys" {
  type = object({
    ssh_private_key_path = string
    ssh_public_key_path  = string
  })
}

# bastion

variable "oci_bastion" {
  type = object({
    bastion_shape                  = string
    create_bastion                 = bool
    bastion_access                 = string
    enable_instance_principal      = bool
    image_ocid                     = string
    image_operating_system         = string
    image_operating_system_version = string
    package_update                 = bool
    package_upgrade                = bool
  })
}

variable "oci_bastion_infra" {
  type = object({
    ig_route_id          = string
    vcn_cidr             = string
    vcn_id               = string
    ad_names             = list(string)
    newbits              = number
    subnets              = number
    availability_domains = number
  })
}
