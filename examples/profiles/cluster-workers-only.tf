# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "cluster_and_workers" {
  source          = "github.com/oracle-terraform-modules/terraform-oci-oke.git?ref=5.x"
  providers       = { oci.home = oci.home }
  tenancy_id      = "ocid1.tenancy..."
  compartment_id  = "ocid1.compartment..."
  ssh_public_key  = "/path/to/ssh_public_key.pem"
  ssh_private_key = "/path/to/ssh_private_key.pem"

  create_vcn = false // *true/false; vcn_id required if false
  vcn_id     = "ocid1.vcn..."

  subnets = { # netnum/newbits if create = true, or id required
    bastion  = { id = "ocid1.subnet..." }
    operator = { id = "ocid1.subnet..." }
    cp       = { id = "ocid1.subnet..." }
    int_lb   = { id = "ocid1.subnet..." }
    pub_lb   = { id = "ocid1.subnet..." }
    workers  = { id = "ocid1.subnet..." }
    pods     = { id = "ocid1.subnet..." }
  }

  nsgs = {
    bastion  = { id = "ocid1.networksecuritygroup..." }
    operator = { id = "ocid1.networksecuritygroup..." }
    cp       = { id = "ocid1.networksecuritygroup..." }
    int_lb   = { id = "ocid1.networksecuritygroup..." }
    pub_lb   = { id = "ocid1.networksecuritygroup..." }
    workers  = { id = "ocid1.networksecuritygroup..." }
    pods     = { id = "ocid1.networksecuritygroup..." }
  }

  create_bastion    = false             // *true/false; bastion_public_ip required if false and needed for access
  bastion_public_ip = "xxx.xxx.xxx.xxx" // if create_bastion = false
  create_operator   = true              // *true/false; required if using extensions
  create_cluster    = true              // *true/false; cluster_id required if false
  cluster_type      = "enhanced"        // *basic/enhanced
  cni_type          = "flannel"         // *flannel/npn

  worker_pools = {
    oke-vm-standard = { size = 1 },
  }
}

resource "local_file" "cluster_kubeconfig" {
  content  = local.kube_config
  filename = pathexpand("~/kubeconfig.${module.cluster_and_workers.state_id}")
}
