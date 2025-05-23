# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # Port numbers
  all_ports               = -1
  apiserver_port          = 6443
  fss_nfs_portmapper_port = 111
  fss_nfs_port_min        = 2048
  fss_nfs_port_max        = 2050
  health_check_port       = 10256
  kubelet_api_port        = 10250
  oke_port                = 12250
  node_port_min           = 30000
  node_port_max           = 32767
  ssh_port                = 22

  # Protocols
  # See https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
  all_protocols   = "all"
  icmp_protocol   = 1
  icmpv6_protocol = 58
  tcp_protocol    = 6
  udp_protocol    = 17


  anywhere          = "0.0.0.0/0"
  anywhere_ipv6     = "::/0"
  rule_type_nsg     = "NETWORK_SECURITY_GROUP"
  rule_type_cidr    = "CIDR_BLOCK"
  rule_type_service = "SERVICE_CIDR_BLOCK"

  # Oracle Services Network (OSN)
  osn = one(data.oci_core_services.all_oci_services.services[*].cidr_block)
}
