# Centralized logging for Amazon ECS using Amazon OpenSearch Serverless

## Table of content

- [Centralized logging for Amazon ECS using Amazon OpenSearch Serverless](#centralized-logging-for-amazon-ecs-using-amazon-opensearch-serverless)
  - [Table of content](#table-of-content)
  - [Solution overview](#solution-overview)
  - [Architecture](#architecture)
  - [Prerequisites](#prerequisites)
  - [Infrastructure](#infrastructure)
  - [Usage](#usage)
  - [Cleanup](#cleanup)
  - [Security](#security)
  - [License](#license)
   

## Solution overview

This repository contains Terraform code to deploy a centralized logging solution for Amazon ECS using Amazon OpenSearch Serverless (AOSS). The solution demonstrates how to efficiently collect and manage logs from Amazon ECS tasks running across multiple AWS accounts and centralize them into a shared OpenSearch Serverless collection. This architecture utilizes AWS FireLens with Fluent Bit to route ECS task logs to a centralized OpenSearch instance, ensuring scalability, security, and cost-efficiency across a multi-account environment.

## Architecture

The solution is designed with a multi-account architecture:

- **Shared Services Account**: Hosts the centralized Amazon OpenSearch Serverless collection, KMS keys for encryption, and cross-account IAM roles
- **Compute Account(s)**: Contains ECS clusters, services, and applications that generate logs to be centralized

Key components:
- Amazon ECS with Fargate for containerized applications
- AWS FireLens with Fluent Bit for log routing
- Amazon OpenSearch Serverless for centralized log storage and analysis
- Cross-account IAM roles for secure log shipping
- VPC endpoints for secure communication
- Application Load Balancers for application access

## Prerequisites

Before deploying the solution, ensure you have:

1. **Terraform**: Install [Terraform v1.8.5](https://releases.hashicorp.com/terraform/1.8.5/) or above
2. **AWS CLI**: Configure AWS credentials for both shared services and compute accounts
3. **Multi-Account Setup**: Access to at least two AWS accounts (shared services and compute)
4. **IAM Permissions**: Administrative access in both accounts to create cross-account roles

Configure AWS credentials:
```shell
[shared-services-profile]
aws_access_key_id = <shared_services_access_key>
aws_secret_access_key = <shared_services_secret_key>

[compute-profile]
aws_access_key_id = <compute_access_key>
aws_secret_access_key = <compute_secret_key>
```

## Infrastructure

The infrastructure is organized into two main Terraform configurations:

### tf-shared-services/
Deploys resources in the shared services account:
- Amazon OpenSearch Serverless collection
- KMS keys for encryption
- Cross-account IAM roles for compute accounts
- OpenSearch access and network policies

### tf-compute/
Deploys resources in compute accounts:
- VPC with public/private subnets
- ECS Cluster with Fargate capacity providers
- ECS Services with FireLens logging configuration
- Application Load Balancers
- Security groups and VPC endpoints
- Cross-account IAM roles for OpenSearch access

**Key AWS Resources Created:**
- Amazon OpenSearch Serverless collection
- Amazon ECS cluster and services
- AWS FireLens with Fluent Bit containers
- Application Load Balancers
- VPC with NAT Gateway
- Cross-account IAM roles and policies
- KMS keys for encryption
- Security groups and VPC endpoints

## Usage

### 1. Deploy Shared Services Infrastructure

First, deploy the shared services infrastructure that will host the centralized OpenSearch collection:

```bash
cd tf-shared-services/
```

Create a `terraform.tfvars` file with your configuration:
```hcl
prefix = "my-logging"
aws_region = "us-west-2"
target_compute_accounts = {
  "dev" = "123456789012"
  "prod" = "987654321098"
}
```

Deploy the infrastructure:
```bash
terraform init
terraform plan
terraform apply
```

### 2. Deploy Compute Infrastructure

Next, deploy the compute infrastructure in your target accounts:

```bash
cd ../tf-compute/
```

Create a `terraform.tfvars` file:
```hcl
prefix = "my-logging"
aws_region = "us-west-2"
primary_cidr = "10.0.0.0/16"
terraform_shared_services_deploy_iam_role_arn = "arn:aws:iam::SHARED-SERVICES-ACCOUNT:role/my-logging-COMPUTE-ACCOUNT-terraform-deployment-role"

ecs_applications = {
  "web-app" = {
    image          = "nginx:latest"
    container_port = 80
    cpu            = 256
    memory         = 512
    desired_count  = 2
  }
}
```

Deploy the infrastructure:
```bash
terraform init
terraform plan
terraform apply
```

### 3. Using the Makefile

Alternatively, you can use the provided Makefile for easier deployment:

```bash
# Deploy shared services
make create-shared-services

# Deploy compute infrastructure
make create-compute
```

### 4. Accessing Logs

Once deployed, logs from your ECS applications will be automatically shipped to the centralized OpenSearch Serverless collection. You can:

1. Access the OpenSearch Dashboards through the AWS Console
2. Create index patterns for your application logs (e.g., `my-logging-web-app-*`)
3. Build visualizations and dashboards for log analysis
4. Set up alerts based on log patterns

### 5. Log Format

Logs are shipped with the following structure:
- **Index Pattern**: `{prefix}-{application-name}-YYYY.MM.DD`
- **Fields**: Standard container logs with additional metadata
- **Retention**: Managed by OpenSearch Serverless policies

## Cleanup

To destroy the infrastructure, run the following commands in reverse order:

```bash
# Destroy compute infrastructure first
cd tf-compute/
terraform destroy

# Then destroy shared services
cd ../tf-shared-services/
terraform destroy
```

Or use the Makefile:
```bash
make destroy-compute
make destroy-shared-services
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License
This library is licensed under the MIT-0 License. See the [LICENSE](LICENSE) file.