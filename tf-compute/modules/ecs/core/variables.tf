variable "prefix" {
  description = "Prefix uniquely identifies AWS resources. Needs to be unique per AWS (sub) account."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "AWS tags that will be applied to all resources."
}

variable "fargate_capacity_provider_weights" {
  type = object({
    fargate_weight      = number
    fargate_spot_weight = number
  })
  description = "Weights to be allocated to fargate capacity provider. Weight of both fargate and fargate spot should total to 100."
  default = {
    fargate_spot_weight = 0
    fargate_weight      = 100
  }

  validation {
    condition     = var.fargate_capacity_provider_weights.fargate_spot_weight + var.fargate_capacity_provider_weights.fargate_weight == 100
    error_message = "Weight of both fargate and fargate spot should total to 100."
  }
}

variable "fargate_base" {
  type        = number
  description = "Number of tasks to run on Fargate before considering weight."
  default     = 20
}

variable "aoss_role_arn" {
  description = "AWS IAM role arn to be assumed by firelens for storing logs on OpenSearch Serverless."
  type        = string
}
