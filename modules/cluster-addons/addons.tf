# Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_containerengine_addon_options" "k8s_addon_options" {
  kubernetes_version = var.kubernetes_version
}

locals {
  supported_addons = [for entry in data.oci_containerengine_addon_options.k8s_addon_options.addon_options : entry.name]
  primary_addons   = ["CertManager"]
  addons_defaults = {
    remove_addon_resources_on_delete = true
    configurations                   = []
    version                          = null
  }
  addons_with_defaults = { for addon_name, addon_value in var.cluster_addons :
    addon_name => merge(local.addons_defaults, addon_value)
  }
}

resource "oci_containerengine_addon" "primary_addon" {
  for_each = { for k, v in local.addons_with_defaults : k => v if contains(local.primary_addons, k) }

  addon_name = each.key
  cluster_id = var.cluster_id

  remove_addon_resources_on_delete = lookup(each.value, "remove_addon_resources_on_delete", true)

  dynamic "configurations" {
    for_each = lookup(each.value, "configurations", [])
    iterator = config

    content {
      key   = tostring(lookup(config.value, "key"))
      value = tostring(lookup(config.value, "value"))
    }
  }
  override_existing = lookup(each.value, "override_existing", false)
  version           = lookup(each.value, "version", null)

  lifecycle {

    precondition {
      condition     = contains(local.supported_addons, each.key)
      error_message = <<-EOT
      The addon ${each.key} is not supported.
      The list of supported addons is: ${join(", ", local.supported_addons)}.
      EOT
    }
  }
}

resource "oci_containerengine_addon" "secondary_addon" {
  for_each   = { for k, v in local.addons_with_defaults : k => v if !contains(local.primary_addons, k) }
  depends_on = [oci_containerengine_addon.primary_addon]
  addon_name = each.key
  cluster_id = var.cluster_id

  remove_addon_resources_on_delete = lookup(each.value, "remove_addon_resources_on_delete", true)

  dynamic "configurations" {
    for_each = lookup(each.value, "configurations", [])
    iterator = config

    content {
      key   = tostring(lookup(config.value, "key"))
      value = tostring(lookup(config.value, "value"))
    }
  }
  override_existing = lookup(each.value, "override_existing", false)
  version           = lookup(each.value, "version", null)

  lifecycle {

    precondition {
      condition     = contains(local.supported_addons, each.key)
      error_message = <<-EOT
      The addon ${each.key} is not supported.
      The list of supported addons is: ${join(", ", local.supported_addons)}.
      EOT
    }
  }
}