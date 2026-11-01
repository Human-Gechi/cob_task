output "team_role_arns" {
  description = "Map of team name to role ARN. Look one up with team_role_arns[\"data\"]."
  value       = { for team, role in aws_iam_role.team : team => role.arn }
}

output "team_role_names" {
  value = { for team, role in aws_iam_role.team : team => role.name }
}

output "team_policy_arns" {
  description = "Map of team name to access policy ARN (only teams that have access defined)."
  value       = { for team, policy in aws_iam_policy.team : team => policy.arn }
}
