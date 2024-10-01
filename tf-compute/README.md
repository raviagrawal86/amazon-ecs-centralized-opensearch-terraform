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
| <a name="provider_aws.shared_services_account"></a> [aws.shared\_services\_account](#provider\_aws.shared\_services\_account) | 5.69.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | git::https://github.com/terraform-aws-modules/terraform-aws-alb.git | 454d2cbf78d48b9eaeb499bfe6dd05fe30b4ae0c |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/cluster | 9a8c7d3cb799ec297d8ae1891616bc2872799ab7 |
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service | 9a8c7d3cb799ec297d8ae1891616bc2872799ab7 |
| <a name="module_kms"></a> [kms](#module\_kms) | git::https://github.com/terraform-aws-modules/terraform-aws-kms.git | fe1beca2118c0cb528526e022a53381535bb93cd |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git | e226cc15a7b8f62fd0e108792fea66fa85bcb4b9 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ecs_task_exec_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.aoss_cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.aoss_cross_account_role_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_opensearchserverless_access_policy.data_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_opensearchserverless_security_policy.network_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_opensearchserverless_vpc_endpoint.vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_vpc_endpoint) | resource |
| [aws_security_group.vpce_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.vpce_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.shared_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.aoss_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.aoss_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_exec_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_opensearchserverless_collection.aoss_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/opensearchserverless_collection) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_fluentbit_image"></a> [aws\_fluentbit\_image](#input\_aws\_fluentbit\_image) | ECR public link for FluentBit container image | `string` | `"906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region where AWS resources will be deployed. | `string` | n/a | yes |
| <a name="input_ecs_applications"></a> [ecs\_applications](#input\_ecs\_applications) | Application to be deployed in the ECS cluster | <pre>map(object({<br>    image          = string<br>    container_port = number<br>    cpu            = number<br>    memory         = number<br>    desired_count  = number<br>  }))</pre> | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix naming for resources created. | `string` | n/a | yes |
| <a name="input_primary_cidr"></a> [primary\_cidr](#input\_primary\_cidr) | VPC subnet in CIDR notation. | `string` | n/a | yes |
| <a name="input_terraform_shared_services_deploy_iam_role_arn"></a> [terraform\_shared\_services\_deploy\_iam\_role\_arn](#input\_terraform\_shared\_services\_deploy\_iam\_role\_arn) | IAM role ARN that Terraform will assume to deploy AWS resources in the shared services account. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->