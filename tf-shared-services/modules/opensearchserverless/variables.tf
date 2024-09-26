variable "prefix" {
  description = "Prefix uniquely identifies AWS resources. Needs to be unique per AWS (sub) account."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "AWS tags that will be applied to all resources."
}

variable "aws_region" {
  description = "Region where Opensearch will be deployed."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy the cluster in."
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
