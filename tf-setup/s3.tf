# S3 bucket for remote Terraform backend
module "s3_bucket" {
  source = "./modules/s3"

  bucket_name = "${var.prefix}-terraform-state-109972344243"
  key_arn     = module.kms.key_arn
  iam_roles   = var.admin_role_arns
}
