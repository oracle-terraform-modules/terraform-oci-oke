# Copyright (c) 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "oci_identity_region_subscriptions" "home" {
  tenancy_id = var.tenancy_ocid
  filter {
    name   = "is_home_region"
    values = [true]
  }
}

data "oci_secrets_secretbundle" "ssh_key" {
  count     = var.create_bastion ? 1 : 0
  secret_id = var.ssh_kms_secret_id
}

locals {
  ssh_key_bundle         = sensitive(one(data.oci_secrets_secretbundle.ssh_key[*].secret_bundle_content))
  ssh_key_bundle_content = sensitive(var.create_bastion ? lookup(one(local.ssh_key_bundle), "content", null) : null)
}

module "oke" {
  source         = "github.com/devoncrouse/terraform-oci-oke.git?ref=5.x-stack&depth=1"
  providers      = { oci.home = oci.home }
  tenancy_id     = var.tenancy_ocid
  compartment_id = var.compartment_ocid

  # Identity
  create_iam_resources     = true
  create_iam_tag_namespace = var.create_iam_tag_namespace
  create_iam_defined_tags  = var.create_iam_tag_namespace || var.create_iam_defined_tags
  use_defined_tags         = var.use_defined_tags
  tag_namespace            = var.tag_namespace

  # Network
  create_vcn                  = var.create_vcn
  vcn_id                      = var.vcn_id
  vcn_cidrs                   = split(",", var.vcn_cidrs)
  vcn_create_internet_gateway = var.vcn_create_internet_gateway ? "always" : "never"
  vcn_create_nat_gateway      = var.vcn_create_nat_gateway ? "always" : "never"
  vcn_create_service_gateway  = var.vcn_create_service_gateway ? "always" : "never"
  vcn_name                    = var.vcn_name
  vcn_dns_label               = var.vcn_dns_label
  assign_dns                  = var.assign_dns
  ig_route_table_id           = var.ig_route_table_id
  local_peering_gateways      = var.local_peering_gateways
  lockdown_default_seclist    = var.lockdown_default_seclist
  nat_gateway_public_ip_id    = var.nat_gateway_public_ip_id
  nat_route_table_id          = var.nat_route_table_id
  create_drg                  = var.create_drg
  drg_id                      = var.drg_id
  drg_display_name            = var.drg_display_name

  subnets = {
    bastion  = { create = var.bastion_subnet_create ? "always" : "never", newbits = var.bastion_subnet_newbits, id = var.bastion_subnet_id }
    operator = { create = var.operator_subnet_create ? "always" : "never", newbits = var.operator_subnet_newbits, id = var.operator_subnet_id }
    cp       = { create = var.control_plane_subnet_create ? "always" : "never", newbits = var.control_plane_subnet_newbits, id = var.control_plane_subnet_id }
    int_lb   = { create = var.int_lb_subnet_create ? "always" : "never", newbits = var.int_lb_subnet_newbits, id = var.int_lb_subnet_id }
    pub_lb   = { create = var.pub_lb_subnet_create ? "always" : "never", newbits = var.pub_lb_subnet_newbits, id = var.pub_lb_subnet_id }
    workers  = { create = var.worker_subnet_create ? "always" : "never", newbits = var.worker_subnet_newbits, id = var.worker_subnet_id }
    pods     = { create = var.pod_subnet_create ? "always" : "never", newbits = var.pod_subnet_newbits, id = var.pod_subnet_id }
    fss      = { create = var.fss_subnet_create ? "always" : "never", newbits = var.fss_subnet_newbits, id = var.fss_subnet_id }
  }

  # Network Security
  create_nsgs                  = var.create_nsgs
  create_nsgs_always           = true
  allow_node_port_access       = var.allow_node_port_access
  allow_pod_internet_access    = var.allow_pod_internet_access
  allow_rules_internal_lb      = var.allow_rules_internal_lb
  allow_rules_public_lb        = var.allow_rules_public_lb
  allow_worker_internet_access = var.allow_worker_internet_access
  allow_worker_ssh_access      = var.allow_worker_ssh_access
  enable_waf                   = var.enable_waf
  bastion_allowed_cidrs        = compact(split(",", var.bastion_allowed_cidrs))
  bastion_nsg_ids              = compact(split(",", var.bastion_nsg_id))
  control_plane_allowed_cidrs  = compact(split(",", var.control_plane_allowed_cidrs))
  control_plane_is_public      = var.control_plane_is_public
  control_plane_nsg_ids        = compact(split(",", var.control_plane_nsg_id))
  fss_nsg_ids                  = compact(split(",", var.fss_nsg_id))
  load_balancers               = lower(var.load_balancers)
  operator_nsg_ids             = compact(split(",", var.operator_nsg_id))
  pod_nsg_ids                  = compact(split(",", var.pod_nsg_id))
  worker_is_public             = var.worker_is_public
  worker_nsg_ids               = compact(split(",", var.worker_nsg_id))

  # Bastion
  bastion_availability_domain = var.bastion_availability_domain
  bastion_image_id            = var.bastion_image_id
  bastion_image_os            = var.bastion_image_os
  bastion_image_os_version    = var.bastion_image_os_version
  bastion_image_type          = lower(var.bastion_image_type)
  bastion_is_public           = var.bastion_is_public
  bastion_shape               = var.bastion_shape
  bastion_upgrade             = var.bastion_upgrade
  bastion_user                = var.bastion_user
  create_bastion              = var.create_bastion

  # SSH
  ssh_public_key  = local.ssh_public_key
  ssh_private_key = sensitive(local.ssh_key_bundle_content)

  # Cluster
  create_cluster          = false
  preferred_load_balancer = lower(var.preferred_load_balancer)
  create_fss              = false
  create_operator         = false

  freeform_tags = { # TODO Remaining tags in schema
    cluster           = {}
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = lookup(var.bastion_tags, "freeformTags", {})
    operator          = {}
    vcn               = {}
  }

  defined_tags = { # TODO Remaining tags in schema
    cluster           = {}
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
    bastion           = lookup(var.bastion_tags, "definedTags", {})
    operator          = {}
    vcn               = {}
  }
}
