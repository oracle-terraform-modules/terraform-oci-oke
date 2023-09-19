# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 1.2.0"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9.0"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }

    oci = {
      source  = "oracle/oci"
      version = ">= 4.119.0"
    }
  }
}
