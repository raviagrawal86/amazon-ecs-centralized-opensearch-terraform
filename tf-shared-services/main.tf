module "kms" {
  #checkov:skip=CKV_TF_1:Terraform registry source cannot be pinned
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  aliases               = ["terraform/${var.prefix}"]
  description           = "${var.prefix} terraform s3 bucket encryption key"
  enable_default_policy = true
  key_owners            = var.admin_role_arns
  key_statements        = local.kms_cloudwatch_access

  tags = local.tags
}

module "es" {
  source = "./modules/opensearchserverless"

  prefix = var.prefix
  tags   = local.tags

  vpc_id         = module.vpc.vpc.vpc_id
  public_subnets = module.vpc.vpc.public_subnets
  kms_key_arn    = module.kms.key_arn
  aws_region     = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  primary_cidr = var.primary_cidr
  prefix       = var.prefix

  tags = local.tags
}
