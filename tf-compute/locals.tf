locals {
  ###########################################
  ### General Local Variables             ###
  ###########################################
  tags = {
    application = var.prefix
    terraform   = "true"
  }

  ###########################################
  ### ECS Variables                       ###
  ###########################################
  container_name               = "ecsdemo-frontend"
  container_port               = 3000
  aoss_cross_account_role_name = "${var.prefix}-aoss-role"
  task_exec_iam_role_name      = "${var.prefix}-ecs-exec-role"

  ###########################################
  # VPC Sizing/AZ configuration           ###
  ###########################################
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  all_subnets     = cidrsubnets(var.primary_cidr, 2, 2, 2, 2)
  private_subnets = slice(local.all_subnets, 2, 4)
  public_subnets  = slice(local.all_subnets, 0, 2)

  ###########################################
  # AOSS Variables & Policies             ###
  ###########################################
  aoss_collection_name = data.aws_opensearchserverless_collection.aoss_logging.name
  # Network policy
  aoss_network_policy = [
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.aoss_collection_name}"
          ]
        }
      ],
      AllowFromPublic = false,
      SourceVPCEs = [
        aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
      ]
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${local.aoss_collection_name}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ]

  aoss_data_access_policy = [
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${local.aoss_collection_name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.aoss_collection_name}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        aws_iam_role.aoss_cross_account_role.arn
      ]
    }
  ]

  ###########################################
  # KMS Key Policy for CloudWatch Logs    ###
  ###########################################
  kms_cloudwatch_access = [
    {
      sid       = "CloudWatchAccess"
      actions   = ["kms:Encrypt*", "kms:Decrypt*", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:Describe*"]
      resources = ["*"]
      principals = [{
        type        = "Service"
        identifiers = ["logs.${var.aws_region}.amazonaws.com"]
      }]
      condition = [{
        test     = "ArnLike"
        variable = "kms:EncryptionContext:aws:logs:arn"
        values   = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:*${var.prefix}*"]
      }]
    }
  ]

}
