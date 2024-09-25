output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.cluster.certificate_arn
}

output "fqdn" {
  description = "The FQDN of the ingress."
  value       = local.ingress_fqdn
}

output "wildcard_cert_arn" {
  description = "The wildcard TLS certificate for the fqdn."
  value       = aws_acm_certificate_validation.cluster.certificate_arn
}
