# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

subnets = {
  bastion  = { newbits = 13 }
  operator = { newbits = 13 }
  cp       = { newbits = 13 }
  int_lb   = { newbits = 11 }
  pub_lb   = { newbits = 11 }
  workers  = { newbits = 2 }
  pods     = { newbits = 2 }
}
