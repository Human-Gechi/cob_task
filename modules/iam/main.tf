module "standard" {
  source = "../standard"

  organisation = var.organisation
  project      = var.project
  environment  = var.environment
  team         = var.team
  extra_tags   = var.extra_tags
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "team" {
  for_each = var.team_access

  name                 = "${module.standard.name_prefix}-${each.key}"
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = var.max_session_duration

  tags = merge(module.standard,
    {
      Team = each.key
  })
}
