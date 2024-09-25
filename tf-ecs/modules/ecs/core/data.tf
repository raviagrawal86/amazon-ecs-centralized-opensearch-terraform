data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs_task_execution_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_execution_permissions_policy" {
  statement {
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:repository/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [var.aoss_role_arn]
  }
}
