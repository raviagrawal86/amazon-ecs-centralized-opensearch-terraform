locals {
  tags = {
    "application" = var.application
    "environment" = var.environment
    "ManagedBy"   = "Terraform"
  }
}