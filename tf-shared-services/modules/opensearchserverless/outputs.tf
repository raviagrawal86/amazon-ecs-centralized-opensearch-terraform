output "opensearch_collection_endpoint" {
  description = "The endpoint URL of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.collection.collection_endpoint
}

output "opensearch_dashboard_endpoint" {
  description = "The dashboard endpoint URL of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.collection.dashboard_endpoint
}
