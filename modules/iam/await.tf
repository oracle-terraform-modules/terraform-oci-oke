resource "time_sleep" "await_iam_resources" {
  count = anytrue([
    local.has_policy_statements_before_cluster,
    local.has_policy_statements_after_cluster,
    local.create_iam_tag_namespace,
  ]) ? 1 : 0
  create_duration  = "30s"
  destroy_duration = "0s"
}
