##############################################
# Creates KMS key to encrypt AOSS Collection  
##############################################
module "kms" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=fe1beca2118c0cb528526e022a53381535bb93cd"
  # version = "3.1.0"
  aliases               = ["terraform/${var.prefix}"]
  description           = "${var.prefix} application kms key"
  enable_default_policy = true
  tags                  = local.tags
}

###############################################
# Creates AOSS Collection & Supporting Policies
###############################################
module "opensearch_serverless" {
  source = "./modules/opensearchserverless"

  opensearch_prefix = var.prefix
  kms_key_arn       = module.kms.key_arn
  opensearch_tags   = local.tags
}

###############################################
# AWS IAM Role & Policy for Terraform to deploy
# resources in Compute accounts
###############################################
resource "aws_iam_policy" "terraform_deployment_policy" {
  name        = "${var.prefix}-terraform-deployment-policy"
  path        = "/"
  description = "IAM policy for Terraform deployments"

  policy = data.aws_iam_policy_document.terraform_deployment_policy.json
  tags   = local.tags
}

resource "aws_iam_role" "terraform_cross_account_deploy_roles" {
  #checkov:skip=CKV_AWS_61:Ensure AWS IAM policy does not allow assume role permission across all services
  for_each = var.target_compute_accounts

  name = "${var.prefix}-${each.value}-terraform-deployment-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${each.value}:root"
        },
        "Action" : "sts:AssumeRole"
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.terraform_deployment_policy.arn]
  tags                = local.tags
}
