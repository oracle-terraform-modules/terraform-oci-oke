# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "random_id" "state_id" {
  byte_length = 6
}

data "oci_identity_availability_domains" "all" {
  compartment_id = local.compartment_id
}

locals {
  # Stable availability domain selection
  ads = data.oci_identity_availability_domains.all.availability_domains
  ad_numbers_to_names = local.ads != null ? {
    for ad in local.ads : parseint(substr(ad.name, -1, -1), 10) => ad.name
  } : { -1 : "" } # Fallback handles failure when unavailable but not required
  ad_numbers = local.ads != null ? sort(keys(local.ad_numbers_to_names)) : []
}
