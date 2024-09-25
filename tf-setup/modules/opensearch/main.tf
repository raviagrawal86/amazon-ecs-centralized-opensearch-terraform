data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_iam_policy_document" "es_access_policy" {
  statement {
    actions   = ["es:*"]
    resources = ["arn:aws:es:${local.es_region}:${data.aws_caller_identity.current.account_id}:domain/${local.name}/*"]

    principals {
      type        = "AWS"
      identifiers = var.admin_role_arns
    }
  }
}

data "aws_iam_policy_document" "es_log_publishing_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = [
      aws_cloudwatch_log_group.es_domain.arn,
      "${aws_cloudwatch_log_group.es_domain.arn}:log-stream:*"
    ]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

# data "aws_iam_policy_document" "es_log_publishing_policy" {
#   statement {
#     actions = [
#       "logs:CreateLogStream"
#     ]

#     resources = [aws_cloudwatch_log_group.es_domain.arn]

#     principals {
#       identifiers = ["es.amazonaws.com"]
#       type        = "Service"
#     }
#   }

#   statement {
#     actions = [
#       "logs:PutLogEvents",
#       "logs:PutLogEventsBatch",
#     ]

#     resources = ["${aws_cloudwatch_log_group.es_domain.arn}:log-stream:*"]

#     principals {
#       identifiers = ["es.amazonaws.com"]
#       type        = "Service"
#     }
#   }
# }

resource "aws_security_group" "es" {
  #checkov:skip=CKV2_AWS_5:This security group does not need attachment
  name        = "es-${var.prefix}"
  description = "VPC and internet access to Elasticsearch"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC and internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = [
      var.vpc_cidr,
      "0.0.0.0/0"
    ]
  }
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.opensearch.domain_name
  access_policies = data.aws_iam_policy_document.es_access_policy.json
}

resource "aws_opensearch_domain" "opensearch" {
  #checkov:skip=CKV_AWS_317:Audit logging is not needed
  #checkov:skip=CKV_AWS_318:Master HA is not needed
  #checkov:skip=CKV2_AWS_59:Master node is not needed
  domain_name     = local.name
  engine_version  = "OpenSearch_${var.es_cluster_version}"
  access_policies = null

  cluster_config {
    dedicated_master_enabled = var.master_instance_enabled
    dedicated_master_count   = var.master_instance_enabled ? var.master_instance_count : null
    dedicated_master_type    = var.master_instance_enabled ? var.master_instance_type : null

    instance_count = var.es_instance_count_multiplier * length(var.public_subnets)
    instance_type  = var.es_instance_type

    warm_enabled = var.warm_instance_enabled
    warm_count   = var.warm_instance_enabled ? var.warm_instance_count : null
    warm_type    = var.warm_instance_enabled ? var.warm_instance_type : null

    zone_awareness_enabled = local.es_zone_awareness_enabled ? true : false
    dynamic "zone_awareness_config" {
      for_each = local.es_zone_awareness_enabled ? [length(var.public_subnets)] : []
      content {
        # fixing to 2 instead of 3 or more it expect max 3.
        availability_zone_count = 2
      }
    }
  }

  vpc_options {
    subnet_ids         = var.public_subnets
    security_group_ids = [aws_security_group.es.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      # master_user_arn = data.aws_caller_identity.current.arn
      master_user_name     = var.es_master_user_name
      master_user_password = random_password.es_domain.result
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_domain.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_arn
  }

  tags = merge(
    {
      "Name" = local.name
    },
    local.tags
  )
}

resource "aws_cloudwatch_log_group" "es_domain" {
  #checkov:skip=CKV_AWS_338:Log retention is good for 2 months
  name              = "/aws/opensearch/${local.name}"
  tags              = local.tags
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = var.kms_key_arn
}

resource "aws_cloudwatch_log_resource_policy" "es_log_publishing_policy" {
  policy_document = data.aws_iam_policy_document.es_log_publishing_policy.json
  policy_name     = "elasticsearch-log-publishing-policy"
}

resource "random_password" "es_domain" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_special      = 2
  min_numeric      = 2
}

# # Argo requires the password to be bcrypt
# resource "bcrypt_hash" "es_domain" {
#   cleartext = random_password.es_domain.result
# }

resource "aws_secretsmanager_secret" "es_domain" {
  #checkov:skip=CKV2_AWS_57:Secret Rotation is not needed
  name                    = "esdomain-masterpassword"
  recovery_window_in_days = 0
  kms_key_id              = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "es_domain" {
  secret_id     = aws_secretsmanager_secret.es_domain.id
  secret_string = random_password.es_domain.result
}
