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

variable "enable_instance_principal" {
  description = "enable the bastion hosts to call OCI API services without requiring api key"
  default     = false
}


variable "preferred_bastion_image" {
  # values = ol (OracleLinux), centos, ubuntu
  default = "ol"
}

variable "imageocids" {
  type = "map"

  default = {
    # https://docs.us-phoenix-1.oraclecloud.com/images/

    # Oracle-Linux-7.6-2018.12
    ol-us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaklifrcpkhjgszalaoitdshyxbxog3wm5ccol55m2apw3fg3mjndq"
    ol-us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaawiur3bi46qsb6egmfqnfhsn66kj74bnvnfxrr7o72wiyuhzy2fba"
    ol-eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaamrvusixu33rzvgvjpfjflwkjeyfwnnoyoefoqxnmttds5vukj4vq"
    ol-uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaannfmrswpgevhcp3de4ngip4vcxi7culiimgm7mi4npiuxwweqrq"
    ol-ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaasbx5hzms4eyrs6e3woez6zxxnfd7yuqtc6bg53jiqevoe52ob4qq"

    # CentOS-7-2018.12.18-0
    centos-us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaa77atxnaou5ykurakjrjybn4efaa7w3tmg47oo3b4v6e4jldkzzlq"
    centos-us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaarsu56scul4muz3sqbptvykipy2rn6re3wzdjvncgcpgqt5cp3wja"
    centos-eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajscyriqmukax7k5tgayq6g26lolscurrcphc4bofty6i6gmq2x2q"
    centos-uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaw2jelcbmlkzu2vde7t6wyanqzrn5xl7likly5xbputixs3gdj6pa"
    centos-ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaa5lcszaeld2nl2zo7g3plaxwufz43sftcmuxeimql7kgcczupvn7a"

    # Ubuntu-18.04-2018.12.10-0
    ubuntu-us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaahuvwlhrckaqyjgntvbjhlunzbv4zwsy6zvczknkstwa4tj3pzmuq"
    ubuntu-us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaahh6wjs5qp2sieliieujdnih7eyxt32ets3nuiifzjjfkqnbelcra"
    ubuntu-eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaqmvdglh5hmonugj5i6w754r3hxbrsxk4luwe6u5ulyyyn4aha2gq"
    ubuntu-uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaasmb4dxiv4p6mpfohuiijs3gxkgtafbng7octzvj7aaebiayx5fca"
    ubuntu-ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaaw6wely3ji4rikswrhiv6r4pgbdl4yms5xwcr4orheivpso6t6fvq"
  }
}


# availability domains

variable "availability_domains" {
  description = "ADs where to provision resources"
  type        = "map"

  default = {
    bastion = "1"
  }
}