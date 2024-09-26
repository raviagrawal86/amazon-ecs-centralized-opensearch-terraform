terraform {
  required_version = ">= 1.1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }

  # backend "s3" {
  #   bucket         = "bayer-veg-ecs-terraform-state-109972344243"
  #   key            = "ecs-setup/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "bayer-veg-ecs-terraform-state-lock"
  # }
}

provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"

  default_tags {
    tags = local.tags
  }
}