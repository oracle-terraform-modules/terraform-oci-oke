# Run with Terraform >= 1.7: terraform -chdir=modules/workers test
# Mock providers keep this regression test independent of OCI credentials.
mock_provider "oci" {
  mock_data "oci_core_image" {
    defaults = {
      operating_system         = "Oracle Linux"
      operating_system_version = "8"
    }
  }
}
mock_provider "cloudinit" {}

variables {
  apiserver_private_host     = "10.0.0.1"
  cluster_id                 = "ocid1.cluster.oc1.iad.test"
  compartment_id             = "ocid1.compartment.oc1..test"
  state_id                   = "test"
  assign_dns                 = false
  assign_public_ip           = false
  pod_subnet_id              = "ocid1.subnet.oc1.iad.test"
  worker_subnet_id           = "ocid1.subnet.oc1.iad.test"
  ad_numbers                 = [1]
  ad_numbers_to_names        = { "1" = "test:US-ASHBURN-AD-1" }
  timezone                   = "UTC"
  agent_config               = null
  image_type                 = "custom"
  image_id                   = "ocid1.image.oc1.iad.test"
  disable_default_cloud_init = true

  cloud_init = [{ content = "#cloud-config", content_type = "text/cloud-config" }]

  worker_pools = merge([
    for ignore_size in [false, true] : {
      for seconds, expected in {
        "0"    = "PT0S"
        "1"    = "PT1S"
        "59"   = "PT59S"
        "60"   = "PT1M"
        "61"   = "PT1M1S"
        "300"  = "PT5M"
        "3540" = "PT59M"
        "3599" = "PT59M59S"
        "3600" = "PT1H"
        "3601" = "PT1H"
        "7200" = "PT1H"
        } : "${ignore_size}-${seconds}" => {
        ignore_initial_pool_size = ignore_size
        eviction_grace_duration  = tonumber(seconds)
        expected_duration        = expected
      }
    }
  ]...)
}

run "canonical_eviction_grace_duration" {
  command = plan

  assert {
    condition = alltrue([
      for name, pool in oci_containerengine_node_pool.tfscaled_workers :
      pool.node_eviction_node_pool_settings[0].eviction_grace_duration == var.worker_pools[name].expected_duration
    ]) && length(oci_containerengine_node_pool.tfscaled_workers) == 11
    error_message = "Terraform-scaled pools must use canonical durations, capped at PT1H."
  }

  assert {
    condition = alltrue([
      for name, pool in oci_containerengine_node_pool.autoscaled_workers :
      pool.node_eviction_node_pool_settings[0].eviction_grace_duration == var.worker_pools[name].expected_duration
    ]) && length(oci_containerengine_node_pool.autoscaled_workers) == 11
    error_message = "Autoscaled pools must use canonical durations, capped at PT1H."
  }
}
