<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.5, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.60.0, < 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.69.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | git::https://github.com/terraform-aws-modules/terraform-aws-kms.git | fe1beca2118c0cb528526e022a53381535bb93cd |
| <a name="module_opensearch_serverless"></a> [opensearch\_serverless](#module\_opensearch\_serverless) | ./modules/opensearchserverless | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.terraform_deployment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.terraform_cross_account_deploy_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.terraform_deployment_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region where AWS resources will be deployed. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix naming for resources created. | `string` | n/a | yes |
| <a name="input_target_compute_accounts"></a> [target\_compute\_accounts](#input\_target\_compute\_accounts) | Map of AWS accounts where ECS solution will be deployed to be monitored by the observability solution. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_alias"></a> [kms\_alias](#output\_kms\_alias) | Alias of the KMS key used for encrypting AOSS. |
| <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn) | ARN of the KMS key used for encrypting AOSS. |
| <a name="output_kms_id"></a> [kms\_id](#output\_kms\_id) | ID of the KMS key used for encrypting AOSS. |
| <a name="output_opensearch_collection_endpoint"></a> [opensearch\_collection\_endpoint](#output\_opensearch\_collection\_endpoint) | The endpoint URL of the OpenSearch Serverless collection |
| <a name="output_opensearch_dashboard_endpoint"></a> [opensearch\_dashboard\_endpoint](#output\_opensearch\_dashboard\_endpoint) | The dashboard endpoint URL of the OpenSearch Serverless collection |
| <a name="output_terraform_cross_account_deploy_roles"></a> [terraform\_cross\_account\_deploy\_roles](#output\_terraform\_cross\_account\_deploy\_roles) | Map of created IAM roles for cross-account deployment |
<!-- END_TF_DOCS -->