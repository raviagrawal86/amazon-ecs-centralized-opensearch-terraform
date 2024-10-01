###########################################
### Contextual Metadata                 ###
###########################################
data "aws_caller_identity" "current" {}

###########################################
### Data elements for Terraform Role    ###
###########################################
data "aws_iam_policy_document" "terraform_deployment_policy" {
  statement {
    sid    = "iam"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListInstanceProfilesForRole",
      "iam:DeleteRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:TagRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:PutRolePolicy",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.prefix}*"]
  }

  statement {
    sid    = "sts"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "aoss"
    effect = "Allow"
    actions = [
      "aoss:BatchGetCollection",
      "aoss:UpdateAccessPolicy",
      "aoss:DeleteSecurityPolicy",
      "aoss:GetAccessPolicy",
      "aoss:CreateAccessPolicy",
      "aoss:CreateSecurityPolicy",
      "aoss:UpdateSecurityPolicy",
      "aoss:DeleteAccessPolicy",
      "aoss:GetSecurityPolicy",
      "aoss:ListTagsForResource"
    ]
    resources = ["*"]
  }
}
