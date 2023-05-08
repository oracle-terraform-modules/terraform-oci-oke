# Copyright 2017, 2023 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source                = "oracle/oci"
      configuration_aliases = [oci.home]
      version               = ">= 4.115.0"
    }
  }
  required_version = ">= 1.2.0"
}
