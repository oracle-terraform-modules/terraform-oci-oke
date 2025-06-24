# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.1"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }

    oci = {
      configuration_aliases = [oci.home]
      source                = "oracle/oci"
      version               = ">= 7.6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
