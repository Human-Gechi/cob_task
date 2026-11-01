data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_zones = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}