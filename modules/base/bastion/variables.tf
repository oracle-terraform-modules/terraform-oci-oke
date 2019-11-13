# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# general

variable "oci_base_identity" {
  type = object({
    api_fingerprint      = string
    api_private_key_path = string
    compartment_id       = string
    tenancy_id           = string
    user_id              = string
  })
  description = "parameters related to oci identity"
}

variable "oci_bastion_general" {
  type = object({
    home_region  = string
    label_prefix = string
    region       = string
  })
  description = "general oci parameters"
}

# bastion

variable "oci_bastion_network" {
  type = object({
    ad_names             = list(string)
    availability_domains = number
    ig_route_id          = string
    netnum               = number
    newbits              = number
    vcn_cidr             = string
    vcn_id               = string
  })
  description = "bastion host networking parameters"
}

variable "oci_bastion" {
  type = object({
    bastion_access      = string
    bastion_enabled     = bool
    bastion_image_id    = string
    bastion_shape       = string
    bastion_upgrade     = bool
    ssh_public_key_path = string
    timezone            = string
    use_autonomous      = bool
  })
  description = "bastion host parameters"
}

variable "oci_bastion_notification" {
  type = object({
    notification_enabled  = bool
    notification_endpoint = string
    notification_protocol = string
    notification_topic    = string
  })
  description = "OCI notification parameters for bastion"
}
