# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_core_shapes" "oke" {
  compartment_id = var.compartment_id
}

locals {
  shapes_by_name = {
    for shape in data.oci_core_shapes.oke.shapes :
    lookup(shape, "name") => shape if contains(keys(shape), "name")
  }

  platform_config_by_shape = {
    for k, v in local.shapes_by_name :
    k => merge(lookup(v, "platform_config_options", [])...)
  }
}
