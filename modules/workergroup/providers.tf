# Copyright (c) 2022 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source                = "oracle/oci"
      version               = ">= 4.67.3"
      configuration_aliases = [oci.home]
    }
  }
  required_version = ">= 1.0.0"
}