output "kms_alias" {
  description = "Alias of the KMS key used for encrypting AOSS."
  value       = module.kms.aliases
}

output "kms_arn" {
  description = "ARN of the KMS key used for encrypting AOSS."
  value       = module.kms.key_arn
}

output "kms_id" {
  description = "ID of the KMS key used for encrypting AOSS."
  value       = module.kms.key_id
}

output "opensearch_collection_endpoint" {
  description = "The endpoint URL of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.opensearch_collection_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "The dashboard endpoint URL of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.opensearch_dashboard_endpoint
}

output "terraform_cross_account_deploy_roles" {
  description = "Map of created IAM roles for cross-account deployment"
  value = {
    for application, role in aws_iam_role.terraform_cross_account_deploy_roles :
    application => {
      name = role.name
      arn  = role.arn
    }
  }
}
