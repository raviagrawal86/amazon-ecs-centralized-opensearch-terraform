# Cluster creation using Terraform community module
# This module enables container insights by default
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.7.4"

  cluster_name = "${var.prefix}-cluster"
  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = var.fargate_capacity_provider_weights.fargate_weight
        base   = var.fargate_base
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = var.fargate_capacity_provider_weights.fargate_spot_weight
      }
    }
  }

  tags = var.tags
}


# Task Execution Role
# This IAM role can be reused and hence we create just one
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.prefix}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role_policy.json
}

resource "aws_iam_role_policy" "ecs_task_execution_permission" {
  name   = "${var.prefix}-ECSTaskAccessPolicy"
  role   = aws_iam_role.ecs_task_execution.id
  policy = data.aws_iam_policy_document.ecs_task_execution_permissions_policy.json
}

