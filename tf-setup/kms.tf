module "kms" {
  #checkov:skip=CKV_TF_1:Terraform registry source cannot be pinned
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  aliases               = ["terraform/${var.prefix}"]
  description           = "${var.prefix} terraform s3 bucket encryption key"
  enable_default_policy = true
  key_owners            = var.admin_role_arns
  key_statements        = local.kms_cloudwatch_access

  tags = local.tags
}
