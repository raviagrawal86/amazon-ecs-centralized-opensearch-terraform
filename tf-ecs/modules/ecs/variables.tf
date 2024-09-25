variable "prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "task_role_arn" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "app_target_group_id" {
  type = string
}

variable "task_custom_policies" {
  type = set(string)
}

variable "container_image" {
  type = string
}

variable "desired_count" {
  default = 1
  type    = number
}

variable "parameters_path" {
  default = ""
  type    = string
}

variable "ecs_webapp_service_registry" {
  type = string
}

variable "aoss_endpoint" {
  type = string
}

variable "aws_fluentbit_image" {
  type = string
}

variable "command" {
  type        = string
  default     = ""
  description = "command to pass to application container (blank for default command)"
}

variable "schedule_expression" {
  type        = string
  default     = ""
  description = "cron expression we should scheduled this ecs service for (blank if not a scheduled service)"
}

variable "scheduled_task_name" {
  type        = string
  default     = ""
  description = "if a scheduled task, give it a specific name"
}
