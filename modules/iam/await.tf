resource "time_sleep" "await_iam_resources" {
  count = anytrue([
    local.has_policy_statements,
    local.create_iam_tag_namespace,
  ]) ? 1 : 0
  create_duration  = "30s"
  destroy_duration = "0s"
}
