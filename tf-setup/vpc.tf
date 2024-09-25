module "vpc" {
  source = "./modules/vpc"

  primary_cidr = var.primary_cidr
  prefix       = var.prefix

  tags = local.tags
}
