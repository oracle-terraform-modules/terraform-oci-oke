# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  state_id                   = coalesce(var.state_id, random_string.state_id.id)
  enable_dual_stack_defaults = var.enable_dual_stack_defaults || var.enable_ipv6
  oke_ip_families            = length(var.oke_ip_families) > 0 ? var.oke_ip_families : local.enable_dual_stack_defaults ? ["IPv4", "IPv6"] : ["IPv4"]
  oke_uses_ipv6              = contains([for family in local.oke_ip_families : upper(family)], "IPV6")
}

resource "random_string" "state_id" {
  length  = 6
  lower   = true
  numeric = false
  special = false
  upper   = false
}

output "state_id" {
  value = local.state_id
}
