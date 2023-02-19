# Copyright (c) 2022, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "random_id" "state_id" {
  byte_length = 6
}

output "state_id" {
  value = random_id.state_id.id
}
