data "aws_availability_zones" "available" {}

module "aws_vpc" {
  #checkov:skip=CKV_TF_1:Terraform registry source cannot be pinned
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = var.prefix
  cidr = local.vpc_cidr
  # secondary_cidr_blocks = [local.secondary_vpc_cidr]
  azs = local.azs

  public_subnets  = local.public_subnets
  private_subnets = local.primary_priv_subnets

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    "karpenter.sh/discovery"                      = local.cluster_name
  }

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.prefix}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.prefix}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.prefix}-default" }

  tags = local.tags
}
