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

variable "team_access" {
  description = "Map of team name to the resources that team may reach. Keys must be Engineering or Data"

  type = map(object({
    s3_read_arns  = optional(list(string), [])
    s3_write_arns = optional(list(string), [])
    secret_arns   = optional(list(string), [])
  }))

  default = {}

  validation {
    condition     = alltrue([for t in keys(var.team_access) : contains(["Engineering", "Data"], t)])
    error_message = "team_access keys must be one of: Engineering or Data"
  }

  validation {
    condition = alltrue([
      for a in values(var.team_access) : alltrue([
        for arn in concat(a.s3_read_arns, a.s3_write_arns, a.secret_arns) : startswith(arn, "arn:aws:")
      ])
    ])
    error_message = "Every entry must be a full ARN starting with arn:aws:. Wildcards such as \"*\" are not allowed."
  }
}

variable "max_session_duration" {
  type    = number
  default = 3600

  validation {
    condition     = var.max_session_duration == 3600
    error_message = "max_session_duration must be with 3600 seconds or an hour."
  }
}
