provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.verrazzano_regions["v8o"]
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
}

provider "oci" {
  fingerprint      = var.api_fingerprint
  private_key_path = var.api_private_key_path
  region           = var.verrazzano_regions["home"]
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  alias            = "home"
}
