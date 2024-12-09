# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "ssh_to_operator" {
  description = "convenient command to ssh to the Admin operator host"
  value       = one(element([module.c1[*].ssh_to_operator], 0))
}