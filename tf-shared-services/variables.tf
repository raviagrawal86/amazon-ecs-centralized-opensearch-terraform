variable "prefix" {
  description = "Unique prefix naming for resources created."
  type        = string
  default     = "bayer-veg-ecs"
}

variable "primary_cidr" {
  description = "VPC subnet in CIDR notation."
  type        = string
  default     = "10.20.0.0/24"
}

variable "admin_role_arns" {
  description = "AWS roles/users that will get admin access to AWS resources."
  type        = list(string)
  default     = ["arn:aws:iam::109972344243:role/gitlab-bayer-ecs", "arn:aws:iam::109972344243:role/Admin"]
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "enable_open_search" {
  description = "Creates a new Amazon Managed open search domain."
  type        = string
  default     = true
}

variable "aws_region" {
  description = "Region where AWS resources will be deployed."
  type        = string
  default     = "us-east-1"
}
