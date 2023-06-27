# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

module "network_only" {
  source         = "github.com/oracle-terraform-modules/terraform-oci-oke.git?ref=5.x"
  providers      = { oci.home = oci.home }
  tenancy_id     = "ocid1.tenancy..."
  compartment_id = "ocid1.compartment..."

  create_bastion  = false // *true/false
  create_cluster  = false // *true/false
  create_operator = false // *true/false

  # Force creation of NSGs with associated components disabled
  nsgs = {
    bastion  = { create = "always" }
    operator = { create = "always" }
    cp       = { create = "always" }
    int_lb   = { create = "always" }
    pub_lb   = { create = "always" }
    workers  = { create = "always" }
    pods     = { create = "always" }
  }

  # Force creation of subnets with associated components disabled
  subnets = {
    bastion  = { create = "always", newbits = 13 }
    operator = { create = "always", newbits = 13 }
    cp       = { create = "always", newbits = 13 }
    int_lb   = { create = "always", newbits = 11 }
    pub_lb   = { create = "always", newbits = 11 }
    workers  = { create = "always", newbits = 4 }
    pods     = { create = "always", newbits = 2 }
  }
}
