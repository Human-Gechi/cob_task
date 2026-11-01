variable "organisation" {
  type    = string
  default = "beejan"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{,20}$", var.organisation))
    error_message = "Organisation must contain at most 20 characters consisting of numbers and digits"
  }
}

variable "project" {
  type    = string
  default = "required"


  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,30}$", var.project))
    error_message = "Project name must contain between 2 to 30 characters consisting of numbers, digits and hypens"
  }
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod"
  }
}

variable "team" {
  type = string
  validation {
    condition     = contains(["Engineering", "Data"], var.team)
    error_message = "team must be one of: Engineering or Data."
  }
}

variable "extra_tags" {
  type = map(string)

  default = {

  }
  validation {
    condition     = length(var.extra_tags) > 0
    error_message = "extra_tags must contain at least one key-value pair"
  }
}