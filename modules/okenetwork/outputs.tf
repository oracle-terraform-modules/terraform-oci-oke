# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "subnet_ids" {
  value = "${
    map(    
      "workers_ad1","${join(",", oci_core_subnet.workers_ad1.*.id)}",
      "workers_ad2","${join(",", oci_core_subnet.workers_ad2.*.id)}",
      "workers_ad3","${join(",", oci_core_subnet.workers_ad3.*.id)}",
      "lb_ad1","${join(",", oci_core_subnet.lb_ad1.*.id)}",
      "lb_ad2","${join(",", oci_core_subnet.lb_ad2.*.id)}",
      "lb_ad3","${join(",", oci_core_subnet.lb_ad3.*.id)}",      
     )  
  }"
}
