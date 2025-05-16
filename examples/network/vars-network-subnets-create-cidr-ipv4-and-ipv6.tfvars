# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

subnets = {
  bastion  = { cidr = "10.0.0.0/29", ipv6_cidr = "8, 0" }
  operator = { cidr = "10.0.0.64/29", ipv6_cidr = "8, 1" }
  cp       = { cidr = "10.0.0.8/29", ipv6_cidr = "8, 2" }
  int_lb   = { cidr = "10.0.0.32/27", ipv6_cidr = "8, 3" }
  pub_lb   = { cidr = "10.0.128.0/27", ipv6_cidr = "8, 4" }
  workers  = { cidr = "10.0.144.0/20", ipv6_cidr = "2603:c020:8010:f002::/64" }
  pods     = { cidr = "10.0.64.0/18", ipv6_cidr = "2603:c020:8010:f003::/64" }
}
