terraform {
  required_version = ">= 1.8.5, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "default"

  default_tags {
    tags = local.tags
  }
}
