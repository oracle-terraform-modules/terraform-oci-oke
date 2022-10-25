# Copyright 2022, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Dynamic resource block for Instance Pool groups defined in worker_groups
resource "oci_core_instance_pool" "instance_pools" {
  # Create an OCI Instance Pool resource for each enabled entry of the worker_groups map with that mode.
  for_each                  = local.enabled_instance_pools
  compartment_id            = lookup(each.value, "compartment_id", local.compartment_id)
  display_name              = join("-", compact([lookup(each.value, "label_prefix", var.label_prefix), each.key]))
  size                      = max(0, lookup(each.value, "size", local.size))
  instance_configuration_id = oci_core_instance_configuration.instance_configuration[each.key].id
  defined_tags              = merge(coalesce(local.defined_tags, {}), contains(keys(each.value), "defined_tags") ? each.value.defined_tags : {})
  freeform_tags             = merge(coalesce(local.freeform_tags, {}), contains(keys(each.value), "freeform_tags") ? each.value.freeform_tags : { worker_group = each.key })

  dynamic "placement_configurations" {
    # Define each configured availability domain for placement, with bounds on # available
    # Configured AD numbers e.g. [1,2,3] are converted into tenancy/compartment-specific names
    iterator = ad_number
    for_each = (contains(keys(each.value), "placement_ads")
      ? tolist(setintersection(each.value.placement_ads, local.ad_numbers))
    : local.ad_numbers)

    content {
      availability_domain = lookup(local.ad_number_to_name, ad_number.value, local.first_ad_name)
      primary_subnet_id   = lookup(each.value, "primary_subnet_id", var.primary_subnet_id)
    }
  }

  lifecycle {
    ignore_changes = [
      display_name, defined_tags, freeform_tags,
      placement_configurations["availability_domain"],
      instance_configuration_id,
    ]
  }

  dynamic "load_balancers" {
    # Associate the instance pool with 0+ load balancers for ingress traffic
    # TODO Accept full definition to create
    for_each = contains(keys(each.value), "load_balancers") ? each.value.load_balancers : {}

    content {
      # TODO From dynamic creation when no lb_id provided; introspected fields when present
      backend_set_name = lookup(lb, "backend_set_name", display_name)
      load_balancer_id = lookup(lb, "lb_id", lb_id)
      port             = lookup(lb, "port", 8080)

      // Possible values are "PrimaryVnic" or the displayName of
      // one of the secondary VNICs on the instance configuration
      // that is associated with the instance pool.
      vnic_selection = lookup(lb, "vnic_selection", "PrimaryVnic") # TODO Support w/ named secondary VNICs
    }
  }

  depends_on = [
    oci_core_instance_configuration.instance_configuration
  ]
}