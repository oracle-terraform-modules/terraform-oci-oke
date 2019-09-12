# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "subnet_ids" {
  value = map(    
      "workers",join(",", oci_core_subnet.workers.*.id),
      "int_lb",join(",", oci_core_subnet.int_lb.*.id),
      "pub_lb",join(",", oci_core_subnet.pub_lb.*.id)
     )    
}

# output "subnet_ids" {
#   value = {
#     for subnet in data.oci_core_subnets.oke_subnets.subnets:
#     substr(subnet.display_name, length(var.label_prefix)+1,length(subnet.display_name)) => subnet.id
#   }
# }