# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # VCN subnet configuration
  # See https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm#vcnconfig
  vcn_cidr = element(var.vcn_cidrs, 0)

  # Filter configured subnets eligible for resource creation
  subnet_cidrs_new = {
    for k, v in var.subnets : k => v
    if lookup(v, "id", null) == null && lookup(v, "create", "auto") != "never"
  }

  # Handle subnets configured with provided CIDRs
  subnet_cidrs_cidr_input = {
    for k, v in local.subnet_cidrs_new : k => lookup(v, "cidr", null) if contains(keys(v), "cidr") && !contains(keys(v), "id")
  }

  # Handle subnets configured with newbits for sizing
  subnet_cidrs_newbits_input = {
    for k, v in local.subnet_cidrs_new : k => lookup(v, "newbits", 1) if contains(keys(v), "newbits") && !contains(keys(v), "id")
  }

  # Generate CIDR ranges for subnets to be created
  subnet_cidrs_newbits_ranges = cidrsubnets(local.vcn_cidr, values(local.subnet_cidrs_newbits_input)...)
  subnet_cidrs_newbits_resolved = length(local.vcn_cidr) > 0 ? {
    for k, v in local.subnet_cidrs_newbits_input : k => element(local.subnet_cidrs_newbits_ranges, index(keys(local.subnet_cidrs_newbits_input), k))
  } : {}

  // Combine provided and calculated subnet CIDRs
  subnet_cidrs_all = merge(local.subnet_cidrs_cidr_input, local.subnet_cidrs_newbits_resolved)

  # Map of subnets for standard components with additional configuration derived
  # TODO enumerate worker pools for public/private overrides, conditional subnets for both
  subnet_info = {
    bastion  = { create = var.create_bastion, is_public = var.bastion_is_public }
    cp       = { create = var.create_cluster, is_public = var.control_plane_is_public }
    workers  = { create = var.create_cluster, is_public = var.worker_is_public }
    pods     = { create = var.create_cluster && var.cni_type == "npn" }
    operator = { create = var.create_operator }
    fss      = { create = var.create_fss }
    int_lb = {
      create         = var.create_cluster && contains(["both", "internal"], var.load_balancers),
      create_seclist = true, dns_label = "ilb",
    }
    pub_lb = {
      create         = var.create_cluster && contains(["both", "public"], var.load_balancers),
      create_seclist = true, is_public = true, dns_label = "plb",
    }
  }

  subnet_output = { for k, v in var.subnets :
    k => lookup(v, "id", null) != null ? v.id : lookup(lookup(oci_core_subnet.oke, k, {}), "id", null)
  }
}

resource "oci_core_subnet" "oke" {
  # Create subnets if when all are true:
  # - Associated component is enabled OR configured with create == 'always'
  # - Subnet CIDR is configured with newbits & netnum
  # - Not configured with create == 'never'
  # - Not configured with an existing 'id'
  for_each = { for k, v in local.subnet_info : k => v
    if(tobool(lookup(v, "create", true)) || lookup(lookup(var.subnets, k, {}), "create", "auto") == "always")
    && contains(keys(local.subnet_cidrs_all), k)
    && lookup(var.subnets, "create", "auto") != "never"
  }

  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  cidr_block                 = lookup(local.subnet_cidrs_all, each.key)
  display_name               = "${each.key}-${var.state_id}"
  dns_label                  = var.assign_dns ? lookup(var.subnets, "id", substr(each.key, 0, 2)) : null
  prohibit_public_ip_on_vnic = !tobool(lookup(each.value, "is_public", false))
  route_table_id             = !tobool(lookup(each.value, "is_public", false)) ? var.nat_route_table_id : var.ig_route_table_id
  security_list_ids          = compact([lookup(lookup(oci_core_security_list.oke, each.key, {}), "id", null)])
  defined_tags               = local.defined_tags
  freeform_tags              = local.freeform_tags

  lifecycle {
    # TODO reflect default security_list_id instead of ignore
    ignore_changes = [security_list_ids, freeform_tags, defined_tags, dns_label]
  }
}

# Create an associated security list for subnets when enabled
# e.g. for load balancers to prevent CCM management of default security list
resource "oci_core_security_list" "oke" {
  for_each = { for k, v in local.subnet_info : k => v if alltrue([
    tobool(lookup(v, "create", true)),
    tobool(lookup(v, "create_seclist", false)),
    contains(keys(local.subnet_cidrs_all), k),
    ])
  }

  compartment_id = var.compartment_id
  display_name   = "${each.key}-${var.state_id}"
  vcn_id         = var.vcn_id
  defined_tags   = local.defined_tags
  freeform_tags  = local.freeform_tags

  lifecycle {
    ignore_changes = [freeform_tags, defined_tags]
  }
}

# Return configured/created subnet IDs when applicable
output "subnet_ids" {
  value = local.subnet_output
}

output "subnet_cidrs" {
  value = local.subnet_cidrs_all
}
