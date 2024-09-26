variable "primary_cidr" {
  description = "VPC subnet in CIDR notation."
  type        = string
}

variable "prefix" {
  description = "Prefix uniquely identifies AWS resources. Needs to be unique per AWS (sub) account."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "AWS tags that will be applied to all resources"
  default     = {}
}
