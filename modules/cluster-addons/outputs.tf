# Copyright (c) 2017, 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "supported_addons" {
  value = data.oci_containerengine_addon_options.k8s_addon_options.addon_options
}
