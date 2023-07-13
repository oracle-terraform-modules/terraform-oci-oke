# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "cluster_workers_only" {
  source          = "../../../"
  providers       = { oci.home = oci }
  tenancy_id      = var.tenancy_id
  compartment_id  = var.compartment_id
  ssh_public_key  = var.ssh_public_key_path

  create_vcn = false // *true/false; vcn_id required if false
  vcn_id     = var.vcn_id
  subnets = var.subnets
  nsgs = var.nsgs

  create_bastion    = false             // *true/false
  bastion_public_ip = var.bastion_public_ip

  create_operator   = true              // *true/false
  create_cluster    = true              // *true/false
  cluster_type      = "enhanced"        // *basic/enhanced
  cni_type          = "flannel"         // *flannel/npn

  worker_pool_size = 1
  worker_pools = {
    oke-pool = {}
  }
}
