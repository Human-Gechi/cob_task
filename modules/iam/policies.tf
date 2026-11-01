data "aws_iam_policy_document" "team" {
  for_each = local.active_teams

  dynamic "statement" {
    for_each = length(each.value.s3_read_arns) + length(each.value.s3_write_arns) > 0 ? [1] : []
    content {
      sid       = "ListBuckets"
      actions   = ["s3:ListBucket"]
      resources = concat(each.value.s3_read_arns, each.value.s3_write_arns)
    }
  }

  dynamic "statement" {
    for_each = length(each.value.s3_read_arns) > 0 ? [1] : []
    content {
      sid       = "ReadObjects"
      actions   = ["s3:GetObject"]
      resources = [for arn in each.value.s3_read_arns : "${arn}/*"]
    }
  }

  dynamic "statement" {
    for_each = length(each.value.s3_write_arns) > 0 ? [1] : []
    content {
      sid       = "WriteObjects"
      actions   = ["s3:GetObject", "s3:PutObject"]
      resources = [for arn in each.value.s3_write_arns : "${arn}/*"]
    }
  }

  dynamic "statement" {
    for_each = length(each.value.secret_arns) > 0 ? [1] : []
    content {
      sid       = "ReadSecrets"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = each.value.secret_arns
    }
  }
}

resource "aws_iam_policy" "team" {
  for_each = local.active_teams

  name   = "${module.standards.name_prefix}-${each.key}-access"
  policy = data.aws_iam_policy_document.team[each.key].json
  tags   = merge(module.standards.tags, { Team = each.key })
}

resource "aws_iam_role_policy_attachment" "team" {
  for_each = local.active_teams

  role       = aws_iam_role.team[each.key].name
  policy_arn = aws_iam_policy.team[each.key].arn
}
