# Copyright 2017, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
      configuration_aliases = [oci.home]
    }
  }
  required_version = ">= 1.0.0"
}
