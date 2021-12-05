# Copyright 2017, 2021 Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  # scripting templates

  install_verrazzano_operator_template = templatefile("${path.module}/scripts/install_verrazzano_operator.template.sh",
    {
      verrazzano_version = var.verrazzano_version
    }
  )

  install_verrazzano_template = templatefile("${path.module}/scripts/install_verrazzano.template.sh",
    {
      verrazzano_name = var.verrazzano_name
    }
  )

}
