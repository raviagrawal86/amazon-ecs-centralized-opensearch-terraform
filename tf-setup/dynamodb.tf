# DynamoDB table for Terraform state lock
resource "aws_dynamodb_table" "terraform_lock" {
  #checkov:skip=CKV2_AWS_16:Autoscaling is not needed due to limited use by terraform

  name           = "${var.prefix}-terraform-state-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = module.kms.key_arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.tags
}
