variable "aws_region" {
  description = "Region where AWS resources will be deployed."
  type        = string
}

variable "application" {
  description = "Application name."
  type        = string
}

variable "environment" {
  description = "Environment where AWS resources will be deployed."
  type        = string
  default     = "nonprod"
}

variable "route53_hosted_zone" {
  description = "Name of the Route53 hosted zone."
  type        = string
  default     = "ravi-agrawal.com"
}

variable "apps" {
  description = "Map of applications that will be deployed to ECS."
  type = map(object({
    container_port = number
    cpu            = number
    memory         = number
    desired_count  = number
  }))
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed."
  type        = string
}

variable "subnets" {
  description = "List of subnets where application should be deployed."
  type        = list(string)
}

variable "aoss_collection_name" {
  description = "AOSS collection where logs should be sent."
  type        = string
}

variable "kms_key_id" {
  description = "KMS ID to be used for encryption purpose."
  type        = string
}

variable "aws_fluentbit_image" {
  description = "ECR public link for FluentBit container image"
  type        = string
  default     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"

}
