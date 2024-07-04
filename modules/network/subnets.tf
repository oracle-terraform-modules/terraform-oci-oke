# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # VCN subnet configuration
  # See https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm#vcnconfig
  # May be undefined when VCN is neither created nor required, e.g. when creating only workers for
  # an existing cluster. Fallback value is unused.
  vcn_cidr = length(var.vcn_cidrs) > 0 ? element(var.vcn_cidrs, 0) : "0.0.0.0/16"

  # Filter configured subnets eligible for resource creation
  subnet_cidrs_new = {
    for k, v in var.subnets : k => merge(v, {
      "type" = (lookup(v, "netnum", null) == null && lookup(v, "newbits", null) != null ? "newbits"
        : (lookup(v, "netnum", null) != null && lookup(v, "newbits", null) != null ? "netnum"
          : (lookup(v, "cidr", null) != null ? "cidr"
            : (lookup(v, "id", null) != null ? "id"
      : "invalid"))))
    }) if try(v.create, "auto") != "never"
  }

  # Handle subnets configured with provided CIDRs
  subnet_cidrs_cidr_input = {
    for k, v in local.subnet_cidrs_new : k => lookup(v, "cidr") if v.type == "cidr"
  }

  # Handle subnets configured with only newbits for sizing
  subnet_cidrs_newbits_input = {
    for k, v in local.subnet_cidrs_new : k => lookup(v, "newbits") if v.type == "newbits"
  }

  # Generate CIDR ranges for subnets to be created
  subnet_cidrs_newbits_ranges = cidrsubnets(local.vcn_cidr, values(local.subnet_cidrs_newbits_input)...)
  subnet_cidrs_newbits_resolved = length(local.vcn_cidr) > 0 ? {
    for k, v in local.subnet_cidrs_newbits_input : k => element(local.subnet_cidrs_newbits_ranges, index(keys(local.subnet_cidrs_newbits_input), k))
  } : {}

  # Handle subnets configured with netnum + newbits for sizing
  subnet_cidrs_netnum_newbits_ranges = {
    for k, v in local.subnet_cidrs_new : k => cidrsubnet(local.vcn_cidr, lookup(v, "newbits"), lookup(v, "netnum"))
    if v.type == "netnum"
  }

  // Combine provided and calculated subnet CIDRs
  subnet_cidrs_all = merge(
    local.subnet_cidrs_cidr_input,
    local.subnet_cidrs_newbits_resolved,
    local.subnet_cidrs_netnum_newbits_ranges,
  )

  # Map of subnets for standard components with additional configuration derived
  # TODO enumerate worker pools for public/private overrides, conditional subnets for both
  subnet_info = {
    bastion  = { create = var.create_bastion, is_public = var.bastion_is_public }
    cp       = { create = var.create_cluster, is_public = var.control_plane_is_public }
    workers  = { create = var.create_cluster, is_public = var.worker_is_public }
    pods     = { create = var.create_cluster && var.cni_type == "npn" }
    operator = { create = var.create_operator }
    fss      = { create = contains(keys(var.subnets), "fss") }
    int_lb = {
      create         = var.create_cluster && contains(["both", "internal"], var.load_balancers),
      create_seclist = true, dns_label = "ilb",
    }
    pub_lb = {
      create         = var.create_cluster && contains(["both", "public"], var.load_balancers),
      create_seclist = true, is_public = true, dns_label = "plb",
    }
  }

  # Map of configured subnets to specified/generated dns_label when enabled
  # If `assign_dns = true`, use dns_label for subnet if specified or first 2 characters of subnet key
  subnet_dns_labels = { for k, v in var.subnets :
    k => coalesce(lookup(v, "dns_label", null), substr(k, 0, 2))
    if var.assign_dns
  }

  # Create subnets if when all are true:
  # - Associated component is enabled OR configured with create == 'always'
  # - Subnet is configured with newbits and/or netnum/cidr
  # - Not configured with create == 'never'
  # - Not configured with an existing 'id'
  subnets_to_create = try(merge(
    { for k, v in local.subnet_info : k =>
      # Override `create = true` if configured with "always"
      merge(v, lookup(try(lookup(var.subnets, k), { create = "never" }), "create", "auto") == "always" ? { "create" = true } : {})
      if alltrue([                                                                              # Filter disabled subnets from output
        contains(keys(local.subnet_cidrs_all), k),                                              # has a calculated CIDR range (not id input)
        lookup(try(lookup(var.subnets, k), { create = "never" }), "create", "auto") != "never", # not disabled
        anytrue([
          tobool(lookup(v, "create", true)),                                                      # automatically enabled
          lookup(try(lookup(var.subnets, k), { create = "never" }), "create", "auto") == "always" # force enabled
        ]),
      ])
    }
  ), {})

  subnet_output = { for k, v in var.subnets :
    k => lookup(v, "id", null) != null ? v.id : lookup(lookup(oci_core_subnet.oke, k, {}), "id", null)
  }
}

resource "null_resource" "validate_subnets" {
  count = anytrue([for k, v in local.subnet_cidrs_new : contains(["netnum", "newbits", "cidr"], v.type)
    if lookup(v, "create", "auto") != "never"
  ]) ? 1 : 0

  lifecycle {
    precondition {
      condition     = !contains([for k, v in local.subnet_cidrs_new : v.type], "invalid")
      error_message = format("Invalid subnet specification: %s", jsonencode({ for k, v in local.subnet_cidrs_new : k => v if v.type == "invalid" }))
    }

    precondition {
      condition = !(contains([for k, v in local.subnet_cidrs_new : v.type], "netnum") && contains([for k, v in local.subnet_cidrs_new : v.type], "newbits"))
      error_message = format(
        "Must omit or include `netnum` for all subnet defintions uniformely: %s",
        jsonencode({ for k, v in local.subnet_cidrs_new : k => v if contains(["netnum", "newbits"], v.type) })
      )
    }
  }
}

resource "oci_core_subnet" "oke" {
  for_each = local.subnets_to_create

  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  cidr_block                 = lookup(local.subnet_cidrs_all, each.key)
  display_name               = format("%v-%v", each.key, var.state_id)
  dns_label                  = lookup(local.subnet_dns_labels, each.key, null)
  prohibit_public_ip_on_vnic = !tobool(lookup(each.value, "is_public", false))
  route_table_id             = !tobool(lookup(each.value, "is_public", false)) ? var.nat_route_table_id : var.ig_route_table_id
  security_list_ids          = compact([lookup(lookup(oci_core_security_list.oke, each.key, {}), "id", null)])
  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags

  lifecycle {
    ignore_changes = [
      freeform_tags, defined_tags, display_name,
      cidr_block, dns_label, security_list_ids, vcn_id, route_table_id,
    ]
  }
}

# Create an associated security list for subnets when enabled
# e.g. for load balancers to prevent CCM management of default security list
resource "oci_core_security_list" "oke" {
  for_each = {
    for k, v in local.subnets_to_create : k => v
    if tobool(lookup(v, "create_seclist", false))
  }

  compartment_id = var.compartment_id
  display_name   = format("%v-%v", each.key, var.state_id)
  vcn_id         = var.vcn_id
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  lifecycle {
    ignore_changes = [
      freeform_tags, defined_tags, display_name, vcn_id,
      ingress_security_rules, egress_security_rules, # ignore for CCM-management
    ]
  }
}

# Return configured/created subnet IDs and CIDRs when applicable
output "bastion_subnet_id" {
  value = lookup(local.subnet_output, "bastion", null)
}
output "bastion_subnet_cidr" {
  value = contains(keys(local.subnet_output), "bastion") ? lookup(local.subnet_cidrs_all, "bastion", null) : null
}
output "operator_subnet_id" {
  value = lookup(local.subnet_output, "operator", null)
}
output "operator_subnet_cidr" {
  value = contains(keys(local.subnet_output), "operator") ? lookup(local.subnet_cidrs_all, "operator", null) : null
}
output "control_plane_subnet_id" {
  value = lookup(local.subnet_output, "cp", null)
}
output "control_plane_subnet_cidr" {
  value = contains(keys(local.subnet_output), "cp") ? lookup(local.subnet_cidrs_all, "cp", null) : null
}
output "int_lb_subnet_id" {
  value = lookup(local.subnet_output, "int_lb", null)
}
output "int_lb_subnet_cidr" {
  value = contains(keys(local.subnet_output), "int_lb") ? lookup(local.subnet_cidrs_all, "int_lb", null) : null
}
output "pub_lb_subnet_id" {
  value = lookup(local.subnet_output, "pub_lb", null)
}
output "pub_lb_subnet_cidr" {
  value = contains(keys(local.subnet_output), "pub_lb") ? lookup(local.subnet_cidrs_all, "pub_lb", null) : null
}
output "worker_subnet_id" {
  value = lookup(local.subnet_output, "workers", null)
}
output "worker_subnet_cidr" {
  value = contains(keys(local.subnet_output), "workers") ? lookup(local.subnet_cidrs_all, "workers", null) : null
}
output "pod_subnet_id" {
  value = lookup(local.subnet_output, "pods", null)
}
output "pod_subnet_cidr" {
  value = contains(keys(local.subnet_output), "pods") ? lookup(local.subnet_cidrs_all, "pods", null) : null
}
output "fss_subnet_id" {
  value = lookup(local.subnet_output, "fss", null)
}
output "fss_subnet_cidr" {
  value = contains(keys(local.subnet_output), "fss") ? lookup(local.subnet_cidrs_all, "fss", null) : null
}
