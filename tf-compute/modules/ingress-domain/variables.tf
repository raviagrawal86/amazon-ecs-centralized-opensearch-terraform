variable "resource_prefix" {
  description = "Prefix uniquely identifies AWS resources. Needs to be unique per AWS (sub) account."
  type        = string

  validation {
    condition     = var.resource_prefix != ""
    error_message = "The resource prefix can not be empty."
  }
}

variable "route53_hosted_zone" {
  description = "The route53 hosted zone to use for the cluster_domain."
  type        = string

  validation {
    condition     = var.route53_hosted_zone != ""
    error_message = "The hosted_zone can not be empty."
  }
}
