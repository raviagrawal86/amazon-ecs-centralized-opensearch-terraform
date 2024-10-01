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

variable "terraform_shared_services_deploy_iam_role_arn" {
  description = "IAM role ARN that Terraform will assume to deploy AWS resources in the shared services account."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::\\d{12}:role/[a-zA-Z0-9+=,.@_-]{1,64}$", var.terraform_shared_services_deploy_iam_role_arn))
    error_message = "The IAM role ARN must be a valid AWS IAM role ARN."
  }
}

variable "aws_fluentbit_image" {
  description = "ECR public link for FluentBit container image"
  type        = string
  default     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"

  validation {
    condition     = can(regex("^\\d{12}\\.dkr\\.ecr\\.[a-z]+-[a-z]+-\\d{1}\\.amazonaws\\.com/[a-z0-9-]+:[a-z0-9-]+$", var.aws_fluentbit_image))
    error_message = "The FluentBit image must be in the format 'account.dkr.ecr.region.amazonaws.com/repository:tag'."
  }
}

variable "primary_cidr" {
  description = "VPC subnet in CIDR notation."
  type        = string

  validation {
    condition     = can(cidrhost(var.primary_cidr, 0))
    error_message = "The primary_cidr must be a valid IPv4 CIDR block."
  }
}

variable "ecs_applications" {
  description = "Application to be deployed in the ECS cluster"
  type = map(object({
    image          = string
    container_port = number
    cpu            = number
    memory         = number
    desired_count  = number
  }))
}
