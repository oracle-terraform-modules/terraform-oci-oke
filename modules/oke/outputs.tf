output "cluster_endpoint" {
  value = "https://${oci_containerengine_cluster.k8s_cluster.endpoints.0.kubernetes}"
}
