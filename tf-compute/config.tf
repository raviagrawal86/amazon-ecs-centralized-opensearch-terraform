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

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "shared_services_account"
  region = var.aws_region

  assume_role {
    role_arn = var.terraform_shared_services_deploy_iam_role_arn
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "central-account"
  region = var.aws_region

  assume_role {
    role_arn = var.terraform_shared_services_deploy_iam_role_arn
  }

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "shared-services-account"
  region = var.aws_region

  assume_role {
    role_arn = var.terraform_shared_services_deploy_iam_role_arn
  }

  default_tags {
    tags = local.tags
  }
}
