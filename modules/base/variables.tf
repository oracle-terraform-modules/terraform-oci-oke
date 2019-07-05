# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Identity and access parameters

variable "api_fingerprint" {
  description = "fingerprint of oci api private key"
}

variable "api_private_key_path" {
  description = "path to oci api private key"
}

variable "compartment_name" {
  type        = "string"
  description = "compartment name"
}

variable "compartment_ocid" {
  type        = "string"
  description = "compartment ocid"
}

variable "tenancy_ocid" {
  type        = "string"
  description = "tenancy id"
}

variable "user_ocid" {
  type        = "string"
  description = "user ocid"
}

# ssh keys

variable "ssh_private_key_path" {
  description = "path to ssh private key"
}

variable "ssh_public_key_path" {
  description = "path to ssh public key"
}


# general oci parameters

variable "disable_auto_retries" {
  default = true
}

variable "label_prefix" {
  type    = "string"
  default = ""
}

variable "region" {
  # List of regions: https://docs.us-phoenix-1.oraclecloud.com/Content/General/Concepts/regions.htm
  description = "region"
  default     = "us-ashburn-1"
}

# networking parameters

variable "newbits" {
  type        = "map"
  description = "new mask for the subnet within the virtual network. use as newbits parameter for cidrsubnet function"

  default = {
    bastion = "8"
  }
}

variable "subnets" {
  type        = "map"
  description = "zero-based index of the subnet when the network is masked with the newbit."

  default = {
    bastion = "11"
  }
}

variable "vcn_cidr" {
  type        = "string"
  description = "cidr block of VCN"
  default     = "10.0.0.0/16"
}

variable "vcn_dns_name" {
  type    = "string"
  default = "baseoci"
}

variable "vcn_name" {
  type        = "string"
  description = "name of vcn"
}

# nat

variable "create_nat_gateway" {
  description = "whether to create a nat gateway"
  default     = false
}

variable "nat_gateway_name" {
  description = "display name of the nat gateway"
  default     = "nat"
}

# service gateway

variable "create_service_gateway" {
  description = "whether to create a service gateway"
  default     = false
}

variable "service_gateway_name" {
  description = "name of service gateway"
  default     = "object_storage_gateway"
}

# bastion

variable "bastion_shape" {
  description = "shape of bastion instance"
  default     = "VM.Standard2.1"
}

variable "create_bastion" {
  default = false
}

variable "bastion_access" {
  description = "cidr from where the bastion can be sshed into. Default is ANYWHERE and equivalent to 0.0.0.0/0"
  default     = "ANYWHERE"
}

variable "enable_instance_principal" {
  description = "enable the bastion hosts to call OCI API services without requiring api key"
  default     = false
}


variable "image_ocid" {
  default = "NONE"
}
variable "image_operating_system" {
  # values = Oracle Linux, CentOS, Canonical Ubuntu
  default = "Oracle Linux"
  description = "operating system to use for the bastion"
}

variable "image_operating_system_version" {
  # Versions of available operating systems can be found here: https://docs.cloud.oracle.com/iaas/images/
  description = "version of selected operating system"
}


# availability domains

variable "availability_domains" {
  description = "ADs where to provision resources"
  type        = "map"

  default = {
    bastion = "1"
  }
}