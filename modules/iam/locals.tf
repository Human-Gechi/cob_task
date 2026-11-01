locals {
  active_teams = {
    for team, access in var.team_access : team => access
    if length(access.s3_read_arns) + length(access.s3_write_arns) + length(access.secret_arns) > 0
  }
}
