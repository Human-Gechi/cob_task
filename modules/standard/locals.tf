locals {
  name_prefix = "${var.organisation}-${var.project}-${var.environment}"
  tags        = merge(var.extra_tags, { Team = var.team })
}

