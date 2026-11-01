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

variable "private_subnet_ids" {
  type        = list(string)
  description = "At least two data subnets in different AZs."
}

variable "allowed_security_group_id" {
  type = string
}

# The database
variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type = string
}

variable "port" {
  type        = number
  default     = 5432
  description = "5432 for postgres, 3306 for mysql."
}

variable "db_name" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_days" {
  type    = number
  default = 1
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}
