locals {
  ingress_fqdn = "${var.resource_prefix}.${var.route53_hosted_zone}"
}

data "aws_region" "current" {}

data "aws_route53_zone" "vended_zone" {
  name         = var.route53_hosted_zone
  private_zone = false
}

resource "aws_acm_certificate" "cluster" {
  domain_name       = "*.${local.ingress_fqdn}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    yor_name             = "cluster"
    yor_trace            = "71323477-7166-4d8b-94cc-6d30e5ab480b"
    git_commit           = "N/A"
    git_file             = "tf-eks-core/modules/disposables/ingress-domain/main.tf"
    git_last_modified_at = "2023-06-16 12:59:46"
    git_last_modified_by = "ravagraw@amazon.com"
    git_modifiers        = "ravagraw"
    git_org              = "bayer-veg-rnd"
    git_repo             = "eks-infrastructure"
    department           = "high-roller"
    env                  = "dev"
    team                 = "devops"
  }
}

resource "aws_route53_record" "domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cluster.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.vended_zone.id
}

resource "aws_acm_certificate_validation" "cluster" {
  certificate_arn         = aws_acm_certificate.cluster.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_validation : record.fqdn]
}
