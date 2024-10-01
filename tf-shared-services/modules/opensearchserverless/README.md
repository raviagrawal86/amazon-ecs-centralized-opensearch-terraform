# Amazon OpenSearch Serverless Example

This module creates an OpenSearch Serverless collection with an encryption, network, and data access policy.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_opensearchserverless_access_policy.dashboard_data_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_opensearchserverless_collection.collection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection) | resource |
| [aws_opensearchserverless_security_policy.encryption_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_opensearchserverless_security_policy.network_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key to be used for encryption. | `string` | n/a | yes |
| <a name="input_opensearch_prefix"></a> [opensearch\_prefix](#input\_opensearch\_prefix) | Prefix to uniquely identify AWS resources for the OpenSearch deployment. | `string` | n/a | yes |
| <a name="input_opensearch_tags"></a> [opensearch\_tags](#input\_opensearch\_tags) | Map of tags to be applied to all OpenSearch resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_opensearch_collection_endpoint"></a> [opensearch\_collection\_endpoint](#output\_opensearch\_collection\_endpoint) | The endpoint URL of the OpenSearch Serverless collection |
| <a name="output_opensearch_dashboard_endpoint"></a> [opensearch\_dashboard\_endpoint](#output\_opensearch\_dashboard\_endpoint) | The dashboard endpoint URL of the OpenSearch Serverless collection |
<!-- END_TF_DOCS -->