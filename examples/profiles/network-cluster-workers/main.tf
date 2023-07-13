# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

provider "oci" {
  config_file_profile = var.config_file_profile
  tenancy_ocid        = var.tenancy_id
  region              = var.region
}

module "network_cluster_workers" {
  source         = "../../../"
  providers      = { oci.home = oci }
  tenancy_id     = var.tenancy_id
  compartment_id = var.compartment_id
  ssh_public_key = var.ssh_public_key_path

  worker_pool_size = 1
  worker_pools = {
    oke-pool = {}
  }
}
