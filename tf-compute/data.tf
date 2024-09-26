data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "observability_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "observability_permissions_policy" {
  statement {
    effect    = "Allow"
    actions   = ["aoss:APIAccessAll"]
    resources = ["*"]
  }
}

data "aws_opensearchserverless_collection" "aoss_logging" {
  provider = aws.central-account
  name     = var.aoss_collection_name
}
