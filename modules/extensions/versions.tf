# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 1.2.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.1"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 3.2.1"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
