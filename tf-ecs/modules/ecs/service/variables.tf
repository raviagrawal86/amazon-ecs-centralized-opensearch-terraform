variable "prefix" {
  type = string
}

variable "service_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "kms_key_id" {
  type = string
}

variable "aoss_endpoint" {
  type = string
}

variable "aws_fluentbit_image" {
  type = string
}

variable "scheduled_task" {
  description = "Schedulded task details. If selected, will create a schedulded task instead of a service."
  type = object({
    enabled    = optional(bool, false)
    name       = optional(string, "")
    expression = optional(string, "")
  })

  default = {}
  validation {
    condition     = alltrue([(var.scheduled_task.enabled == false) || (length(var.scheduled_task.name) > 0 != null && length(var.scheduled_task.expression) > 0)])
    error_message = "name and expression are mandatory fields when creating a schedulded task."
  }
}

variable "log_retention_period" {
  type        = number
  default     = 90
  description = "Number of days CloudWatch logs will be retained."
}

# ECS variables
variable "ecs_cluster_name" {
  description = "ECS cluster name where service will be deployed."
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "ecr_repository_url" {
  description = "ECR repository url"
  type        = string
}

variable "ecr_image_tag" {
  description = "App tag version"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ECS task execution role ARN."
}

// Config overwrites
variable "ecs_overwrites" {
  # type = object({
  # ecs_task_cpu
  # ecs_task_memory
  # desired_count
  # deployment_maximum_percent
  # deployment_minimum_healthy_percent
  # assign_public_ip
  # })
  type    = map(string)
  default = {}
}


// VPC
variable "vpc_id" {
  description = "VPC Id"
  type        = string
}

variable "private_subnets" {
  description = "VPC private subnets"
  type        = list(string)
}

variable "route53_hosted_zone" {
  description = "Route53 details for the service. Name and wildcard certificate are needed."
  type = object({
    hosted_zone_name    = string
    acm_certificate_arn = string
    service_fqdn        = string
    private_hosted_zone = optional(bool, false)
  })
}

variable "aoss_role_arn" {
  description = "AWS IAM role arn to be assumed by firelens for storing logs on OpenSearch Serverless."
  type        = string
}
