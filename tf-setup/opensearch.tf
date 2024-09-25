module "es" {
  source = "./modules/opensearchserverless"
  count  = var.enable_open_search ? 1 : 0

  prefix = var.prefix
  tags   = local.tags

  vpc_id         = module.vpc.vpc.vpc_id
  public_subnets = module.vpc.vpc.public_subnets
  kms_key_arn    = "arn:aws:kms:us-east-1:109972344243:key/a0b621f8-a1e2-416f-90bc-1f093c38fdae"
  aws_region     = var.aws_region
}
