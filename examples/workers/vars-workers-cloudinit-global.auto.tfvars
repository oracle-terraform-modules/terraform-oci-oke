# Copyright (c) 2017, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

worker_cloud_init = [
  {
    content      = <<-EOT
    runcmd:
    - echo "Global cloud_init using cloud-config"
    EOT
    content_type = "text/cloud-config",
  },
  {
    content      = "/path/to/file"
    content_type = "text/cloud-boothook",
  },
  {
    content      = "<Base64-encoded content>"
    content_type = "text/x-shellscript",
  },
]
