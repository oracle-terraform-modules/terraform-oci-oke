# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "workers_only" {
  source         = "github.com/oracle-terraform-modules/terraform-oci-oke.git?ref=5.x"
  providers      = { oci.home = oci.home }
  tenancy_id     = "ocid1.tenancy..."
  compartment_id = "ocid1.compartment..."

  create_vcn        = false // *true/false; vcn_id required if false
  vcn_id            = "ocid1.vcn..."
  create_bastion    = false             // *true/false; bastion_public_ip required if false and needed for access
  bastion_public_ip = "xxx.xxx.xxx.xxx" // if create_bastion = false
  create_cluster    = false             // *true/false; cluster_id required if false
  cluster_id        = "ocid1.cluster..."
  create_operator   = false // *true/false; required if using extensions

  subnets = {
    workers = { id = "ocid1.subnet..." }
    pods    = { id = "ocid1.subnet..." }
  }

  nsgs = {
    workers = { id = "ocid1.networksecuritygroup..." }
    pods    = { id = "ocid1.networksecuritygroup..." }
  }

  worker_pools = {
    oke-vm-standard = { size = 1 },

    oke-vm-extra = {
      size      = 1,
      subnet_id = "ocid1.subnet...",
      nsg_ids   = ["ocid1.networksecuritygroup..."],

      // Used when cni_type = "npn":
      pod_nsg_ids = ["ocid1.networksecuritygroup..."],
    },
  }
}
