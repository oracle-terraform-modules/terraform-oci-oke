terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      # pass oci home region provider explicitly for identity operations
      version               = ">= 4.67.3"
    }
  }
  required_version = ">= 1.0.0"
}