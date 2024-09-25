output "es_cluster_name" {
  description = "The name of the OpenSearch cluster."
  value       = aws_opensearch_domain.opensearch.domain_name
}

output "es_cluster_version" {
  description = "The version of the OpenSearch cluster."
  value       = replace(aws_opensearch_domain.opensearch.engine_version, "OpenSearch_", "")
}

output "es_cluster_endpoint" {
  description = "The endpoint URL of the OpenSearch cluster."
  value       = "https://${aws_opensearch_domain.opensearch.endpoint}"
}
