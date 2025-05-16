# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# All configuration for network sub-module w/ defaults

# Virtual Cloud Network (VCN)
assign_dns               = true # *true/false
create_vcn               = true # *true/false
local_peering_gateways   = {}
lockdown_default_seclist = true            # *true/false
vcn_id                   = null            # Ignored if create_vcn = true
vcn_cidrs                = ["10.0.0.0/16"] # Ignored if create_vcn = false
vcn_dns_label            = "oke"           # Ignored if create_vcn = false
vcn_name                 = "oke"           # Ignored if create_vcn = false
enable_ipv6              = false           # true/*false

# Subnets
subnets = {
  bastion  = { newbits = 13 }
  operator = { newbits = 13 }
  cp       = { newbits = 13 }
  int_lb   = { newbits = 11 }
  pub_lb   = { newbits = 11 }
  workers  = { newbits = 2 }
  pods     = { newbits = 2 }
}

# Security
allow_node_port_access       = true          # *true/false
allow_pod_internet_access    = true          # *true/false
allow_worker_internet_access = false         # true/*false
allow_worker_ssh_access      = false         # true/*false
control_plane_allowed_cidrs  = ["0.0.0.0/0"] # e.g. "0.0.0.0/0"
control_plane_nsg_ids        = []            # Additional NSGs combined with created
control_plane_type           = "public"      # public/*private
enable_waf                   = false         # true/*false
load_balancers               = "both"        # public/private/*both
preferred_load_balancer      = "public"      # public/*private
worker_nsg_ids               = []            # Additional NSGs combined with created
worker_type                  = "private"     # public/*private

# See https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
# Protocols: All = "all"; ICMP = 1; TCP  = 6; UDP  = 17
# Source/destination type: NSG ID: "NETWORK_SECURITY_GROUP"; CIDR range: "CIDR_BLOCK"
allow_rules_internal_lb = {
  # "Allow TCP ingress to internal load balancers for port 8080 from VCN" : {
  #   protocol = 6, port = 8080, source = "10.0.0.0/16", source_type = "CIDR_BLOCK",
  # },
}

allow_rules_public_lb = {
  # "Allow TCP ingress to public load balancers for SSL traffic from anywhere" : {
  #   protocol = 6, port = 443, source = "0.0.0.0/0", source_type = "CIDR_BLOCK",
  # },
  # "Allow UDP egress to workers port range 50000-52767 from Public LBs" : {
  #   protocol = 17, destination_port_min = 50000, destination_port_max=52767, destination = "workers", destination_type = "NETWORK_SECURITY_GROUP"
  # },
}

allow_rules_workers = {
  # "Allow TCP ingress to workers for port 8080 from VCN" : {
  #   protocol = 6, port = 8080, source = "10.0.0.0/16", source_type = "CIDR_BLOCK",
  # },
  # "Allow UDP ingress to workers for port range 50000-52767 from Public LBs" : {
  #   protocol = 17, destination_port_min = 50000, destination_port_max=52767, source = "pub_lb", source_type = "NETWORK_SECURITY_GROUP"
  # },
  # "Allow TCP ingress to workers for port range 8888-8888 from existing NSG" : {
  #   protocol = 6, destination_port_min = 8888, destination_port_max=8888, source = "ocid1.networksecuritygroup.oc1.eu-frankfurt-1.aaaaaaaai6z4le2ji7dkpmuwff4525b734wrjlifjqkrzlr5qctgxdsyoyra", source_type = "NETWORK_SECURITY_GROUP"
  # },
}

# Dynamic routing gateway (DRG)
create_drg       = false # true/*false
drg_display_name = "drg"
drg_id           = null

# Routing
ig_route_table_id   = null # Optional ID of existing internet gateway route table
internet_gateway_id = null # Optional ID of existing internet gateway
internet_gateway_route_rules = [
  #   {
  #     destination       = "192.168.0.0/16" # Route Rule Destination CIDR
  #     destination_type  = "CIDR_BLOCK"     # only CIDR_BLOCK is supported at the moment
  #     network_entity_id = "drg"            # for internet_gateway_route_rules input variable, you can use special strings "drg", "internet_gateway" or pass a valid OCID using string or any Named Values
  #     description       = "Terraformed - User added Routing Rule: To drg provided to this module. drg_id, if available, is automatically retrieved with keyword drg"
  #   },
]

igw_ngw_mixed_route_id = null # Optional ID of existing mixed route table NAT GW for IPv4 and Internet GW for IPv6

nat_gateway_id           = null # Optional ID of existing NAT gateway
nat_gateway_public_ip_id = "none"
nat_route_table_id       = null # Optional ID of existing NAT gateway route table
nat_gateway_route_rules = [
  #   {
  #     destination       = "192.168.0.0/16" # Route Rule Destination CIDR
  #     destination_type  = "CIDR_BLOCK"     # only CIDR_BLOCK is supported at the moment
  #     network_entity_id = "drg"            # for nat_gateway_route_rules input variable, you can use special strings "drg", "nat_gateway" or pass a valid OCID using string or any Named Values
  #     description       = "Terraformed - User added Routing Rule: To drg provided to this module. drg_id, if available, is automatically retrieved with keyword drg"
  #   },
]
