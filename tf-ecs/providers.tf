provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "central-account"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::747273909328:role/bayer-veg-terraform-deploy-role"
  }
}