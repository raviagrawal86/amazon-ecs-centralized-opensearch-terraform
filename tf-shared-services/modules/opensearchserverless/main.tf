###########################################
# Creates an AOSS serverless collection   
###########################################
resource "aws_opensearchserverless_collection" "collection" {
  name       = length(local.collection_name) > 24 ? substr(local.collection_name, 0, 24) : local.collection_name
  tags       = local.tags
  depends_on = [aws_opensearchserverless_security_policy.encryption_policy]
}

###########################################
# Creates an encryption security policy
###########################################
resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = "${var.opensearch_prefix}-encryption"
  type        = "encryption"
  description = "Encryption policy for ${local.collection_name}"
  policy      = local.aoss_collection_encryption_policy
}

###########################################
# Data access policy for dashboard
###########################################
resource "aws_opensearchserverless_access_policy" "dashboard_data_access_policy" {
  name        = "${var.opensearch_prefix}-dashboard"
  type        = "data"
  description = "Data access policy for dashboard - ${local.collection_name}"
  policy      = local.aoss_collection_data_access_policy
}

###########################################
# Network access policy for dashboard
###########################################
resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = "${var.opensearch_prefix}-dashboard"
  type        = "network"
  description = "Network policy to allow public access for ${local.collection_name} endpoint"
  policy      = local.aoss_network_policy
}