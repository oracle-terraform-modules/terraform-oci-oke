# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  worker_image_id   = coalesce(var.worker_image_custom_id, var.worker_image_platform_id, "none")
  worker_image_type = contains(["platform", "custom"], lower(var.worker_image_type)) ? "custom" : "oke"

  worker_cloud_init = var.worker_cloud_init_configure ? [{
    content_type = "text/x-shellscript",
    content      = var.worker_pool_mode == "Node Pool" ? var.worker_cloud_init_oke : var.worker_cloud_init_byon
  }] : []
}

module "oke" {
  source    = "github.com/oracle-terraform-modules/terraform-oci-oke.git?ref=5.x&depth=1"
  providers = { oci.home = oci.home }

  # Identity
  tenancy_id     = var.tenancy_ocid
  compartment_id = var.compartment_ocid

  create_iam_resources         = true
  create_iam_autoscaler_policy = var.create_iam_autoscaler_policy ? "always" : "never"
  create_iam_worker_policy     = var.create_iam_worker_policy ? "always" : "never"
  create_bastion               = false
  create_operator              = false
  create_cluster               = false

  # Network
  create_vcn     = false
  vcn_id         = var.vcn_id
  assign_dns     = var.assign_dns
  worker_nsg_ids = compact([var.worker_nsg_id])
  pod_nsg_ids    = compact([var.pod_nsg_id])

  subnets = {
    workers = { create = "never", id = var.worker_subnet_id }
    pods    = { create = "never", id = var.pod_subnet_id }
  }

  nsgs = {
    workers = { create = "never", id = var.worker_nsg_id }
    pods    = { create = "never", id = var.pod_nsg_id }
  }

  # Cluster
  cluster_id              = var.cluster_id
  cni_type                = lower(var.cni_type)
  control_plane_is_public = false # workers only need private

  # Workers
  ssh_public_key   = local.ssh_public_key
  worker_pool_size = var.worker_pool_size
  worker_pool_mode = lookup({
    "Node Pool"       = "node-pool"
    "Instances"       = "instances"
    "Instance Pool"   = "instance-pool",
    "Cluster Network" = "cluster-network",
  }, var.worker_pool_mode, "node-pool")

  worker_image_type       = lower(local.worker_image_type)
  worker_image_id         = local.worker_image_id
  worker_image_os         = var.worker_image_os
  worker_image_os_version = var.worker_image_os_version
  worker_cloud_init       = local.worker_cloud_init

  worker_shape = {
    shape            = var.worker_shape
    ocpus            = var.worker_ocpus
    memory           = var.worker_memory
    boot_volume_size = var.worker_boot_volume_size
  }

  worker_pools = {
    format("%v", var.worker_pool_name) = {
      description = lookup({
        "Node Pool"       = "OKE-managed Node Pool"
        "Instances"       = "Self-managed Instances"
        "Instance Pool"   = "Self-managed Instance Pool"
        "Cluster Network" = "Self-managed Cluster Network"
      }, var.worker_pool_mode, "")
    }
  }

  freeform_tags = {
    workers = lookup(var.worker_tags, "freeformTags", {})
  }

  defined_tags = {
    workers = lookup(var.worker_tags, "definedTags", {})
  }
}
