# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "bastion_public_ips" {
  value = "${
    map(    
      "ad1","${join(",", data.oci_core_vnic.bastion_vnic_ad1.*.public_ip_address)}",
      "ad2","${join(",", data.oci_core_vnic.bastion_vnic_ad2.*.public_ip_address)}",
      "ad3","${join(",", data.oci_core_vnic.bastion_vnic_ad3.*.public_ip_address)}"
     )  
  }"
}
