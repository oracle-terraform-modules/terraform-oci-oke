provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key      = var.api_private_key
  region           = var.region
  tenancy_ocid     = local.tenancy_id
  user_ocid        = local.user_id
}

provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key      = var.api_private_key
  region           = var.home_region
  tenancy_ocid     = local.tenancy_id
  user_ocid        = local.user_id
  alias = "home"
}