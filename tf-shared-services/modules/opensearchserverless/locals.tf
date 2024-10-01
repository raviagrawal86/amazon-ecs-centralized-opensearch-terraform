locals {
  ###########################################
  # General Local Variables               ###
  ###########################################
  tags            = var.opensearch_tags
  collection_name = var.opensearch_prefix

  ###########################################
  # AOSS Encryption Policy                ###
  ###########################################
  aoss_collection_encryption_policy = jsonencode({
    Rules = [
      {
        Resource     = [format("collection/%s", local.collection_name)]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = false
    KmsARN      = var.kms_key_arn
  })

  #########################################
  # AOSS Data Access Policy              ###
  #########################################
  aoss_collection_data_access_policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource = [
            format("index/%s/*", local.collection_name),
          ]
          Permission = ["aoss:*"]
        },
        {
          ResourceType = "collection"
          Resource = [
            format("collection/%s", local.collection_name)
          ]
          Permission = ["aoss:*"]
        }
      ]
      Principal = [data.aws_iam_session_context.current.issuer_arn]
    }
  ])

  aoss_network_policy = jsonencode([
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
