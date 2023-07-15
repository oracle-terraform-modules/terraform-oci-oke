# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

provider "oci" {
  config_file_profile = var.config_file_profile
  tenancy_ocid        = var.tenancy_id
  region              = var.region
}

module "workers_only" {
  source              = "../../../"
  providers           = { oci.home = oci }
  tenancy_id          = var.tenancy_id
  compartment_id      = var.compartment_id
  vcn_id              = var.vcn_id
  bastion_public_ip   = var.bastion_public_ip
  cluster_id          = var.cluster_id
  operator_private_ip = var.operator_private_ip
  ssh_public_key_path = var.ssh_public_key_path

  create_vcn      = false
  create_bastion  = false
  create_cluster  = false
  create_operator = false

  subnets = {
    workers = { id = var.worker_subnet_id }
  }

  nsgs           = {}
  worker_nsg_ids = var.worker_nsg_ids

  worker_pool_size = 1
  worker_pools = {
    oke-pool = {}
  }
}
