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

variable "name" {
  type    = string
  default = "default-bucket"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.name))
    error_message = "Name must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}
variable "versioning" {
  type    = bool
  default = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules keyed by rule name. Each needs at least one action."

  type = map(object({
    prefix                 = optional(string, "")
    expire_days            = optional(number)
    noncurrent_expire_days = optional(number)
    transition = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))

  default = {}

  validation {
    condition = alltrue([
      for r in values(var.lifecycle_rules) :
      r.expire_days != null || r.noncurrent_expire_days != null || length(r.transition) > 0
    ])
    error_message = "Each lifecycle rule needs at least one of: expire_days, noncurrent_expire_days, transitions."
  }

  validation {
    condition = alltrue(flatten([
      for r in values(var.lifecycle_rules) : [
        for t in r.transition : contains(
          ["STANDARD_IA", "GLACIER_IR", "GLACIER"],
          t.storage_class
        )
      ]
    ]))
    error_message = "storage_class must be STANDARD_IA, GLACIER_IR, GLACIER"
  }

  validation {
    condition = alltrue(flatten([
      for r in values(var.lifecycle_rules) : concat(
        [for t in r.transition : t.days > 0],
        [r.expire_days == null ? true : r.expire_days > 0]
      )
    ]))
    error_message = "All day values must be greater than zero."
  }
}