# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  identity_domain_name = coalesce(var.identity_domain_name, "Default" )
  isDefaultIdentityDomain = local.identity_domain_name == "Default" ? true : false
}

data "oci_identity_domains" "domains" {
  count = local.isDefaultIdentityDomain ? 0 : 1

  #Required
  compartment_id = var.tenancy_id # dynamic groups exist in the parent compartment.

  #Optional
  display_name = var.identity_domain_name
  #home_region_url = var.domain_home_region_url  ## TODO: provide the home region
  #is_hidden_on_login = var.domain_is_hidden_on_login
  #license_type = var.domain_license_type
  #name = var.domain_name
  #state = var.domain_state
  #type = var.domain_type
  #url = var.domain_url

  provider = oci.home
}
