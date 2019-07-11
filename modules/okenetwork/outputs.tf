# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "subnet_ids" {
  value = map(    
      "workers_ad1",join(",", oci_core_subnet.workers_ad1.*.id),
      "workers_ad2",join(",", oci_core_subnet.workers_ad2.*.id),
      "workers_ad3",join(",", oci_core_subnet.workers_ad3.*.id),
      "int_lb_ad1",join(",", oci_core_subnet.int_lb_ad1.*.id),
      "int_lb_ad2",join(",", oci_core_subnet.int_lb_ad2.*.id),
      "int_lb_ad3",join(",", oci_core_subnet.int_lb_ad3.*.id),
      "pub_lb_ad1",join(",", oci_core_subnet.pub_lb_ad1.*.id),
      "pub_lb_ad2",join(",", oci_core_subnet.pub_lb_ad2.*.id),
      "pub_lb_ad3",join(",", oci_core_subnet.pub_lb_ad3.*.id)
     )    
}