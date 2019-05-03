output "cluster_endpoint" {
  value = "${oci_containerengine_cluster.k8s_cluster.endpoints.kubernetes}"
}
