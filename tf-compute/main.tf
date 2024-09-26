module "ecs_cluster" {
  source = "./modules/ecs/core"

  prefix = "${var.application}-${var.environment}"
  fargate_capacity_provider_weights = {
    fargate_spot_weight = 100
    fargate_weight      = 0
  }
  aoss_role_arn = aws_iam_role.observability_cross_account_role.arn
  tags          = local.tags
}

module "ingress_domain" {
  source = "./modules/ingress-domain"

  resource_prefix     = "${var.application}-${var.environment}"
  route53_hosted_zone = var.route53_hosted_zone
}

module "ecs_service_app" {
  source   = "./modules/ecs/service"
  for_each = { for index, app in var.apps : index => app }

  prefix                      = "${var.application}-${var.environment}"
  service_name                = each.key
  ecs_cluster_name            = module.ecs_cluster.ecs_cluster_name
  ecs_task_execution_role_arn = module.ecs_cluster.ecs_task_execution_role_arn

  kms_key_id          = var.kms_key_id
  aoss_endpoint       = trimprefix(data.aws_opensearchserverless_collection.aoss_logging.collection_endpoint, "https://")
  aoss_role_arn       = aws_iam_role.observability_cross_account_role.arn
  aws_fluentbit_image = var.aws_fluentbit_image

  ecr_repository_url = "public.ecr.aws/aws-containers/ecsdemo-frontend"
  ecr_image_tag      = "776fd50"

  container_port = each.value.container_port
  ecs_overwrites = {
    ecs_task_cpu     = each.value.cpu
    ecs_task_memory  = each.value.memory
    desired_count    = each.value.desired_count
    assign_public_ip = true
  }

  vpc_id          = var.vpc_id
  private_subnets = var.subnets

  route53_hosted_zone = {
    hosted_zone_name    = var.route53_hosted_zone
    acm_certificate_arn = module.ingress_domain.acm_certificate_arn
    service_fqdn        = "${each.key}.${module.ingress_domain.fqdn}"
  }

  tags = local.tags
}

# AOSS Cross Account Role
resource "aws_iam_role" "observability_cross_account_role" {
  provider           = aws.central-account
  name               = "${var.application}-${var.environment}-observability-role"
  assume_role_policy = data.aws_iam_policy_document.observability_assume_role_policy.json
}

resource "aws_iam_role_policy" "observability_cross_account_role_permission" {
  provider = aws.central-account
  name     = "${var.application}-${var.environment}-observability-role-policy"
  role     = aws_iam_role.observability_cross_account_role.id
  policy   = data.aws_iam_policy_document.observability_permissions_policy.json
}

# Data Access Policy
# Creates a data access policy
resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  provider    = aws.central-account
  name        = "${var.application}-${var.environment}-data-access"
  type        = "data"
  description = "allow index and collection access"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${var.aoss_collection_name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${var.aoss_collection_name}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        aws_iam_role.observability_cross_account_role.arn
      ]
    }
  ])
}

# # Creates a VPC endpoint
resource "aws_opensearchserverless_vpc_endpoint" "vpc_endpoint" {
  name               = "${var.application}-${var.environment}-aoss"
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnets
  security_group_ids = [aws_security_group.vpce_security_group.id]
}

# Creates a network security policy
resource "aws_opensearchserverless_security_policy" "network_policy" {
  provider    = aws.central-account
  name        = "${var.application}-${var.environment}-network"
  type        = "network"
  description = "VPC endpoint access for ${var.aoss_collection_name} endpoint"
  policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${var.aoss_collection_name}"
          ]
        }
      ],
      AllowFromPublic = false,
      SourceVPCEs = [
        aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
      ]
    },
  ])
}

# Creates a security group
resource "aws_security_group" "vpce_security_group" {
  #checkov:skip=CKV2_AWS_5:The AOSS security group allows CIDR ingress and is attached to AOSS
  description = "Security group for ${var.application}-${var.environment}-aoss"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.application}-${var.environment}-aoss"
  }
}

# Allows all outbound traffic
resource "aws_vpc_security_group_egress_rule" "sg_egress" {
  security_group_id = aws_security_group.vpce_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Allows inbound traffic from app containers
resource "aws_vpc_security_group_ingress_rule" "sg_ingress" {
  for_each          = { for index, app in var.apps : index => app }
  security_group_id = aws_security_group.vpce_security_group.id

  referenced_security_group_id = module.ecs_service_app[each.key].app_security_group
  ip_protocol                  = "-1"
}
