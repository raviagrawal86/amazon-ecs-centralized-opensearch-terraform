locals {
  tags     = var.tags
  vpc_cidr = var.primary_cidr
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  # secondary_vpc_cidr     = "100.64.0.0/16"
  primary_priv_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 2, k + 2)]
  # secondary_priv_subnets = [for k, v in local.azs : cidrsubnet(local.secondary_vpc_cidr, 8, k + 10)]
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 2, k)]

  # cluster_name = "${var.prefix}-cluster"
  cluster_name = "eks-demo-cluster"
  # private_subnet_ids        = length(module.aws_vpc.private_subnets) > 0 ? slice(module.aws_vpc.private_subnets, 0, 3) : []
  # primary_private_subnet_id = length(module.aws_vpc.private_subnets) > 0 ? slice(module.aws_vpc.private_subnets, 0, 1) : []
}
