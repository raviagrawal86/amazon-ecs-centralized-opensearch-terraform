variable "opensearch_prefix" {
  description = "Prefix to uniquely identify AWS resources for the OpenSearch deployment."
  type        = string

  validation {
    condition     = length(var.opensearch_prefix) <= 20
    error_message = "The opensearch_prefix must be less than or equal to 20 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]*$", var.opensearch_prefix))
    error_message = "The opensearch_prefix must contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to be used for encryption."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-zA-Z0-9-]+$", var.kms_key_arn))
    error_message = "The kms_key_arn must be a valid AWS KMS key ARN."
  }
}

variable "opensearch_tags" {
  description = "Map of tags to be applied to all OpenSearch resources."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.opensearch_tags : can(regex("^[a-zA-Z0-9-_]+$", key)) && can(regex("^[a-zA-Z0-9-_]+$", value))
    ])
    error_message = "Each tag key and value must contain only alphanumeric characters, underscores, and hyphens."
  }
}
