provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.region
  tenancy_id     = var.tenancy_id
  user_id        = var.user_id
}

provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.home_region
  tenancy_id     = var.tenancy_id
  user_id        = var.user_id
  alias            = "home"
}
