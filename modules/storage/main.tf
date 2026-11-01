module "standard" {
  source = "../standard"

  organisation = var.organisation
  project      = var.project
  environment  = var.environment
  team         = var.team
  extra_tags   = var.extra_tags
}


resource "aws_s3_bucket" "main" {
  bucket = "${modules.standard.name_prefix}-${var.name}"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_cycle" {
  bucket = aws_s3_bucket.bucket_name.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.key
      status = "Enabled"

      filter {
        prefix = rule.value.prefix != "" ? rule.value.prefix : null
      }

      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expire_days != null ? [rule.value.expire_days] : []
        content {
          days = expiration.value
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_expire_days != null ? [rule.value.noncurrent_expire_days] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}


resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}