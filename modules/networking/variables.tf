variable "organisation" {
  type = string
}
variable "project" {
  type = string
}
variable "environment" {
  type = string
}
variable "team" {
  type = string
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    condition = (
      can(cidrhost(var.vpc_cidr, 0)) &&
      tonumber(split("/", var.vpc_cidr)[1]) >= 16 &&
      tonumber(split("/", var.vpc_cidr)[1]) <= 24
    )
    error_message = "vpc_cidr mask size has to be within ranges 16 and 24"
  }
}

variable "az_count" {
  type    = number
  default = 2

  validation {
    condition     = var.az_count == 2 || var.az_count == 3
    error_message = "availability zones should be either two or three never one"
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway for private subnets. Costs about 32 USD per month; set false when nothing in a private subnet needs internet access."
  type        = bool
  default     = true
}