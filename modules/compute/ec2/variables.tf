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

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "Provide at least one subnet id."
  }
}

variable "name" {
  type = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,19}$", var.name))
    error_message = "name must be 1 to 20 characters: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type. dev is limited to t3 types"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "t3.large"], var.instance_type)
    error_message = "instance_type must be one of: t3.micro, t3.small, t3.medium, t3.large"
  }
}

variable "instance_count" {
  type    = number
  default = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "instance_count must be between 1 and 5."
  }
}


variable "ami_id" {
  type        = string
  default     = null
  description = "Optional AMI id. If null, the latest Amazon Linux 2023 AMI is used."
}

variable "user_data" {
  type        = string
  default     = null
  description = "Optional cloud-init / shell script run at first boot, e.g. to install and configure a web server."
}

variable "user_data_replace_on_change" {
  type        = bool
  default     = true
  description = "Replace the instance when user_data changes. Keeps instances matching the code in Git."
}