###########################################
### Contextual Metadata                 ###
###########################################
data "aws_caller_identity" "current" {}
data "aws_caller_identity" "shared_services" {
  provider = aws.shared_services_account
}
data "aws_availability_zones" "available" {}

###########################################
### Data elements for ECS Task Exec Role ##
###########################################
data "aws_iam_policy_document" "ecs_task_exec_permissions" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::${data.aws_caller_identity.shared_services.account_id}:role/${local.aoss_cross_account_role_name}"]
  }
}

###########################################
### Data elements for AOSS Role         ###
###########################################
data "aws_iam_policy_document" "aoss_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [module.ecs_cluster.task_exec_iam_role_arn]
    }
  }
}

data "aws_iam_policy_document" "aoss_permissions_policy" {
  statement {
    effect    = "Allow"
    actions   = ["aoss:APIAccessAll"]
    resources = [data.aws_opensearchserverless_collection.aoss_logging.arn]
  }
}

###########################################
### Data element for AOSS Collection    ###
###########################################
data "aws_opensearchserverless_collection" "aoss_logging" {
  provider = aws.shared_services_account
  name     = var.prefix
}
