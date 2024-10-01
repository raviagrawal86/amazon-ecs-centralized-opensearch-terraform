variable "prefix" {
  description = "Unique prefix naming for resources created."
  type        = string

  validation {
    condition     = length(var.prefix) > 0 && length(var.prefix) <= 15
    error_message = "The prefix must be between 1 and 15 characters long."
  }
}

variable "aws_region" {
  description = "Region where AWS resources will be deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "The AWS region must be in the format 'xx-xxxx-#', e.g., 'us-west-2'."
  }
}

variable "target_compute_accounts" {
  description = "Map of AWS accounts where ECS solution will be deployed to be monitored by the observability solution."
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.target_compute_accounts) > 0
    error_message = "At least one target compute account must be provided."
  }

  validation {
    condition     = alltrue([for v in values(var.target_compute_accounts) : can(regex("^\\d{12}$", v))])
    error_message = "All AWS account IDs must be exactly 12 digits long."
  }
}
