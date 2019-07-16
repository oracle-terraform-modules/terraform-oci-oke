# Copyright 2017, 2019, Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Protocols are specified as protocol numbers.
# http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml

locals {
  all_protocols = "all"
  anywhere      = "0.0.0.0/0"
  ssh_port      = 22
  tcp_protocol  = 6
}
