variable "prefix" {
  description = "Prefix uniquely identifies AWS resources. Needs to be unique per AWS (sub) account."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "AWS tags that will be applied to all resources."
}

variable "aws_region" {
  description = "Region where AMP will be deployed."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy the cluster in."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR to deploy the cluster in."
  type        = string
}

variable "public_subnets" {
  description = "Public subnets to deploy the es domain."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "The KMS ARN to be used for encryption."
  type        = string
}

variable "es_cluster_version" {
  description = "The version of OpenSearch to deploy."
  type        = string
  default     = "1.3"
}

variable "es_master_user_name" {
  description = "Master username for Opensearch cluster."
  type        = string
  default     = "master"
}

variable "master_instance_enabled" {
  description = "Indicates whether dedicated master nodes are enabled for the cluster."
  type        = bool
  default     = false
}

variable "master_instance_type" {
  description = "The type of EC2 instances to run for each master node. A list of available instance types can you find at https://aws.amazon.com/en/opensearch-service/pricing/#On-Demand_instance_pricing"
  type        = string
  default     = "r6gd.large.search"

  validation {
    condition     = can(regex("^[m3|r3|i3|i2|r6gd]", var.master_instance_type))
    error_message = "The EC2 master_instance_type must provide a SSD or NVMe-based local storage."
  }
}

variable "master_instance_count" {
  description = "The number of dedicated master nodes in the cluster."
  type        = number
  default     = 3
}

variable "es_instance_count_multiplier" {
  description = "This number is multiplied by availability zone count to get instance count."
  type        = number
  default     = 1
}

variable "es_instance_type" {
  description = "The type of EC2 instances to run for each hot node. A list of available instance types can you find at https://aws.amazon.com/en/opensearch-service/pricing/#On-Demand_instance_pricing"
  type        = string
  default     = "r6gd.large.search"

  validation {
    condition     = can(regex("^[m3|r3|i3|i2|r6gd]", var.es_instance_type))
    error_message = "The EC2 hot_instance_type must provide a SSD or NVMe-based local storage."
  }
}

variable "warm_instance_enabled" {
  description = "Indicates whether ultrawarm nodes are enabled for the cluster."
  type        = bool
  default     = false
}

variable "warm_instance_type" {
  description = "The type of EC2 instances to run for each warm node. A list of available instance types can you find at https://aws.amazon.com/en/elasticsearch-service/pricing/#UltraWarm_pricing"
  type        = string
  default     = "ultrawarm1.large.search"
}

variable "warm_instance_count" {
  description = "The number of dedicated warm nodes in the cluster."
  type        = number
  default     = 2
}

variable "admin_role_arns" {
  description = "AWS roles that will get admin access to ES domain."
  type        = list(string)
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days CloudWatch logs will be retained."
  type        = number
  default     = 60
}
