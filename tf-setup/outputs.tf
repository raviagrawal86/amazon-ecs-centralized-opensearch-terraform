output "dynamodb_table_id" {
  value = aws_dynamodb_table.terraform_lock.id
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.terraform_lock.arn
}

output "kms_aliases" {
  value = module.kms.aliases
}

output "kms_arn" {
  value = module.kms.key_arn
}

output "kms_id" {
  value = module.kms.key_id
}

output "s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_name
}

output "vpc_id" {
  value = module.vpc.vpc.vpc_id
}

output "vpc_azs" {
  value = module.vpc.vpc.azs
}

output "public_subnets" {
  value = module.vpc.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.vpc.private_subnets
}

# output "es_cluster_name" {
#   description = "The name of the OpenSearch cluster."
#   value       = module.es[0].es_cluster_name
# }

# output "es_cluster_endpoint" {
#   description = "The endpoint URL of the OpenSearch cluster."
#   value       = module.es[0].es_cluster_endpoint
# }
