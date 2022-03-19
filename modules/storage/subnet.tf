# fss mount point network provisioning
resource "oci_core_subnet" "fss" {
  cidr_block                 = local.fss_subnet
  compartment_id             = var.compartment_id
  display_name               = var.label_prefix == "none" ? "fss" : "${var.label_prefix}-fss"
  dns_label                  = "fss"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.nat_route_id
  vcn_id                     = var.vcn_id

}
