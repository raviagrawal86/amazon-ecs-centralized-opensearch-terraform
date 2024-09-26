data "aws_caller_identity" "current" {}

# Creates an encryption security policy
resource "aws_opensearchserverless_security_policy" "encryption_policy" {
  name        = "${var.prefix}-encryption-policy"
  type        = "encryption"
  description = "encryption policy for ${local.collection_name}"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${local.collection_name}"
        ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = false
    KmsARN      = var.kms_key_arn
  })
}

# Creates a collection
resource "aws_opensearchserverless_collection" "collection" {
  name = local.collection_name

  tags = local.tags

  depends_on = [aws_opensearchserverless_security_policy.encryption_policy]
}

# Creates a network security policy
resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = "${var.prefix}-network-policy"
  type        = "network"
  description = "public access for dashboard, VPC access for ${local.collection_name} endpoint"
  policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.collection_name}"
          ]
        }
      ],
      AllowFromPublic = false,
      SourceVPCEs = [
        aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
      ]
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${local.collection_name}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

# Creates a VPC endpoint
resource "aws_opensearchserverless_vpc_endpoint" "vpc_endpoint" {
  name               = "${var.prefix}-aoss-vpc-endpoint"
  vpc_id             = var.vpc_id
  subnet_ids         = var.public_subnets
  security_group_ids = [aws_security_group.security_group.id]
}

# Creates a data access policy
resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  name        = "${var.prefix}-data-access-policy"
  type        = "data"
  description = "allow index and collection access"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${local.collection_name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.collection_name}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}

# Creates a security group
resource "aws_security_group" "security_group" {
  #checkov:skip=CKV2_AWS_5:AOSS securoty group cannot be attached.
  description = "Security group for ${var.prefix}-aoss-security-group"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.prefix}-aoss-security-group"
  }
}

# Allows all outbound traffic
resource "aws_vpc_security_group_egress_rule" "sg_egress" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Allows inbound traffic from within security group
resource "aws_vpc_security_group_ingress_rule" "sg_ingress" {
  security_group_id = aws_security_group.security_group.id

  referenced_security_group_id = aws_security_group.security_group.id
  ip_protocol                  = "-1"
}