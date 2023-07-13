# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

subnets = {
  bastion = {
    create  = "always",
    netnum  = 0,
    newbits = 13
  }

  operator = {
    create  = "always",
    netnum  = 1,
    newbits = 13
  }

  cp = {
    create  = "always",
    netnum  = 2,
    newbits = 13
  }

  int_lb = {
    create  = "always",
    netnum  = 16,
    newbits = 11
  }

  pub_lb = {
    create  = "always",
    netnum  = 17,
    newbits = 11
  }

  workers = {
    create  = "always",
    netnum  = 1,
    newbits = 2
  }
}
