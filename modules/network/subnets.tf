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
              : (lookup(v, "netnum", null) != null ? "invalid"
      : "none")))))
    }) if lookup(v, "create", "auto") != "never"
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

  # Handle subnets configured with IPv4 CIDR lists.
  subnet_ipv4cidr_blocks_all = {
    for k, v in local.subnet_cidrs_new : k => v.ipv4_cidrs
    if length(coalesce(lookup(v, "ipv4_cidrs", null), [])) > 0
  }

  // Combine provided and calculated subnet CIDRs
  subnet_cidrs_all = merge(
    local.subnet_cidrs_cidr_input,
    local.subnet_cidrs_newbits_resolved,
    local.subnet_cidrs_netnum_newbits_ranges,
  )

  # IPv6 Default CIDRs
  default_ipv6_cidrs = {
    bastion  = { ipv6_cidr = "8, 0" }
    operator = { ipv6_cidr = "8, 1" }
    cp       = { ipv6_cidr = "8, 2" }
    int_lb   = { ipv6_cidr = "8, 3" }
    pub_lb   = { ipv6_cidr = "8, 4" }
    workers  = { ipv6_cidr = "8, 5" }
    pods     = { ipv6_cidr = "8, 6" }
    fss      = { ipv6_cidr = "8, 7" }
  }

  # Add default ipv6 cidrs to var.subnets if missing
  subnets_with_ipv6_cidr_defaults = { for k, v in var.subnets :
    k => merge(v, var.enable_dual_stack_defaults && lookup(v, "ipv6_cidr", null) == null ? lookup(local.default_ipv6_cidrs, k, { "ipv6_cidr" : null }) : {})
  }

  ipv6_subnet_cidr_offsets_requested = anytrue([
    for k, v in local.subnets_with_ipv6_cidr_defaults :
    length(regexall("^\\d+,[ ]?\\d+$", coalesce(lookup(v, "ipv6_cidr", null), "none"))) > 0
    if try(v.create, "auto") != "never"
  ])

  # Generate IPv6 CIDRs
  subnets_ipv6_cidr = {
    for k, v in local.subnets_with_ipv6_cidr_defaults : k => merge(v, {
      "ipv6_cidr" = length(regexall("^\\d+,[ ]?\\d+$", coalesce(lookup(v, "ipv6_cidr", null), "none"))) > 0 ? try(cidrsubnet(var.vcn_ipv6_cidrs[0], tonumber(split(",", lookup(v, "ipv6_cidr"))[0]), tonumber(trim(split(",", lookup(v, "ipv6_cidr"))[1], " "))), null) : lookup(v, "ipv6_cidr", null)
    }) if try(v.create, "auto") != "never" && lookup(v, "ipv6_cidr", null) != null
  }

  # Handle subnets configured with IPv6 CIDR lists.
  subnet_ipv6cidr_blocks_all = {
    for k, v in local.subnet_cidrs_new : k => v.ipv6_cidrs
    if length(coalesce(lookup(v, "ipv6_cidrs", null), [])) > 0
  }

  ipv6_network_enabled = length(local.subnets_ipv6_cidr) > 0 || length(local.subnet_ipv6cidr_blocks_all) > 0

  subnet_address_input_keys = distinct(concat(
    keys(local.subnet_cidrs_all),
    keys(local.subnet_ipv4cidr_blocks_all),
    keys(local.subnets_ipv6_cidr),
    keys(local.subnet_ipv6cidr_blocks_all),
  ))

  # Map of subnets for standard components with additional configuration derived
  # TODO enumerate worker pools for public/private overrides, conditional subnets for both
  subnet_info = {
    bastion  = { create = var.create_bastion, is_public = var.bastion_is_public }
    cp       = { create = var.create_cluster, is_public = var.enable_dual_stack_defaults == true ? true : var.control_plane_is_public }
    workers  = { create = var.create_cluster, is_public = var.enable_dual_stack_defaults == true ? true : var.worker_is_public }
    pods     = { create = var.create_cluster && var.cni_type == "npn", is_public = var.enable_dual_stack_defaults == true ? true : false }
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
  subnets_to_create = merge(
    { for k, v in var.subnets : k => merge(v, { "is_public" = lookup(v, "is_public", false) })
      if alltrue([
        lookup(v, "id", null) == null,          # doesn't have an OCID
        lookup(v, "create", "auto") != "never", # not disabled
        contains(local.subnet_address_input_keys, k),
        !contains(keys(local.subnet_info), k)
      ])
    },
    { for k, v in local.subnet_info : k =>
      # Override `create = true` if configured with "always"
      merge(v, lookup(try(lookup(var.subnets, k), { create = "never" }), "create", "auto") == "always" ? { "create" = true } : {})
      if alltrue([                                                                              # Filter disabled subnets from output
        contains(local.subnet_address_input_keys, k),                                           # has CIDR input (not id input)
        lookup(try(lookup(var.subnets, k), { create = "never" }), "create", "auto") != "never", # not disabled
        anytrue([
          tobool(lookup(v, "create", true)),                                                      # automatically enabled
          lookup(try(lookup(var.subnets, k), { create = "never" }), "create", "auto") == "always" # force enabled
        ]),
      ])
    }
  )

  subnet_output = { for k, v in var.subnets :
    k => lookup(v, "id", null) != null ? v.id : lookup(lookup(oci_core_subnet.oke, k, {}), "id", null)
  }

}

resource "null_resource" "validate_subnets" {
  count = length(local.subnet_cidrs_new) > 0 ? 1 : 0

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

    precondition {
      condition = alltrue([
        for k, v in local.subnet_cidrs_new : lookup(v, "id", null) == null || alltrue([
          !contains(["netnum", "newbits", "cidr"], v.type),
          length(coalesce(lookup(v, "ipv4_cidrs", null), [])) == 0,
          lookup(v, "ipv6_cidr", null) == null,
          length(coalesce(lookup(v, "ipv6_cidrs", null), [])) == 0,
        ])
      ])
      error_message = format(
        "Subnet IDs are exclusive with CIDR inputs: %s",
        jsonencode({ for k, v in local.subnet_cidrs_new : k => v if lookup(v, "id", null) != null && anytrue([
          contains(["netnum", "newbits", "cidr"], v.type),
          length(coalesce(lookup(v, "ipv4_cidrs", null), [])) > 0,
          lookup(v, "ipv6_cidr", null) != null,
          length(coalesce(lookup(v, "ipv6_cidrs", null), [])) > 0,
        ]) })
      )
    }

    precondition {
      condition = alltrue([
        for k, v in local.subnet_cidrs_new : length(compact([
          contains(["netnum", "newbits", "cidr"], v.type) ? "single" : "",
          length(coalesce(lookup(v, "ipv4_cidrs", null), [])) > 0 ? "list" : "",
        ])) <= 1
      ])
      error_message = format(
        "Must specify only one IPv4 CIDR source per subnet: %s",
        jsonencode({ for k, v in local.subnet_cidrs_new : k => v if length(compact([
          contains(["netnum", "newbits", "cidr"], v.type) ? "single" : "",
          length(coalesce(lookup(v, "ipv4_cidrs", null), [])) > 0 ? "list" : "",
        ])) > 1 })
      )
    }

    precondition {
      condition = alltrue([
        for k, v in local.subnet_cidrs_new : !(lookup(v, "ipv6_cidr", null) != null && length(coalesce(lookup(v, "ipv6_cidrs", null), [])) > 0)
      ])
      error_message = format(
        "Must specify only one IPv6 CIDR source per subnet: %s",
        jsonencode({ for k, v in local.subnet_cidrs_new : k => v if lookup(v, "ipv6_cidr", null) != null && length(coalesce(lookup(v, "ipv6_cidrs", null), [])) > 0 })
      )
    }

    precondition {
      condition = alltrue([
        for k, v in local.subnet_cidrs_new : lookup(v, "id", null) != null || contains(local.subnet_address_input_keys, k)
      ])
      error_message = format(
        "Subnet must specify an ID or at least one IPv4/IPv6 CIDR source: %s",
        jsonencode({ for k, v in local.subnet_cidrs_new : k => v if lookup(v, "id", null) == null && !contains(local.subnet_address_input_keys, k) })
      )
    }

    precondition {
      condition = local.ipv6_network_enabled || alltrue([
        for k, v in local.subnet_cidrs_new : lookup(v, "ipv6_cidr", null) == null && length(coalesce(lookup(v, "ipv6_cidrs", null), [])) == 0
      ])
      error_message = format(
        "IPv6 subnet CIDRs require IPv6 networking: %s",
        jsonencode({ for k, v in local.subnet_cidrs_new : k => v if lookup(v, "ipv6_cidr", null) != null || length(coalesce(lookup(v, "ipv6_cidrs", null), [])) > 0 })
      )
    }

    precondition {
      condition     = !local.ipv6_subnet_cidr_offsets_requested || length(var.vcn_ipv6_cidrs) > 0
      error_message = "IPv6 subnet CIDR offsets require at least one VCN IPv6 CIDR block. Enable Oracle GUA IPv6, configure vcn_ipv6_ula_cidrs or vcn_byoipv6cidr_details when creating the VCN, or use explicit subnet IPv6 CIDRs."
    }
  }
}

resource "oci_core_subnet" "oke" {
  for_each = local.subnets_to_create

  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  cidr_block     = lookup(local.subnet_cidrs_all, each.key, null)
  display_name = (lookup(var.subnets, each.key, null) != null ?
    (lookup(var.subnets[each.key], "display_name", null) != null ?
      var.subnets[each.key]["display_name"] :
      format("%v-%v", each.key, var.state_id)
    ) :
    format("%v-%v", each.key, var.state_id)
  )
  dns_label                  = lookup(local.subnet_dns_labels, each.key, null)
  prohibit_public_ip_on_vnic = !tobool(lookup(each.value, "is_public", false))
  route_table_id             = var.enable_dual_stack_defaults && var.cni_type == "npn" && each.key == "pods" ? var.igw_ngw_mixed_route_id : !tobool(lookup(each.value, "is_public", false)) ? var.nat_route_table_id : var.ig_route_table_id
  security_list_ids          = compact([lookup(lookup(oci_core_security_list.oke, each.key, {}), "id", null)])
  defined_tags               = var.defined_tags
  freeform_tags              = var.freeform_tags
  ipv6cidr_block             = lookup(lookup(local.subnets_ipv6_cidr, each.key, {}), "ipv6_cidr", null)
  ipv4cidr_blocks            = lookup(local.subnet_ipv4cidr_blocks_all, each.key, null)
  ipv6cidr_blocks            = lookup(local.subnet_ipv6cidr_blocks_all, each.key, null)

  lifecycle {
    ignore_changes = [
      freeform_tags, defined_tags,
      cidr_block, dns_label, security_list_ids, vcn_id,
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

output "subnet_ids" {
  value = {
    for k, v in local.subnet_output : k => {
      id   = v
      cidr = lookup(local.subnet_cidrs_all, k, null)
    }
  }
}
