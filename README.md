# ecs-infrastructure

This repository contains the IaC code needed to setup the ECS cluster with required addons for the XYZ application.

## Getting started

Follow these steps for the first time deployment steps

1. Deploy the GitLab role to the target account using the following CfN template, updating the GitLab:Group and GitLab:Project for the repository. This role will be assumed by Terraform to build AWS resources.

  ```bash
  aws cloudformation deploy \
    --stack-name ecs-terraform-gitlab-role \
    --template-file gitlab.yaml \
    --capabilities CAPABILITY_NAMED_IAM
  ```

2. Create S3 bucket and DynamoDB table for Terraform backend. This needs to be done just once since different prefixes within the s3 bucket can hold different state files.

- Change directory `cd tf-setup`
- Comment S3 backend at the bottom of `backend.tf`
- Initialize Terraform `terraform init`
- Ensure only the required resources are created `terraform plan`
- Apply the changes `terraform apply -auto-approve`
- Once the changes are applied successfully, uncomment the S3 backend within `backend.tf`
- Perform `terraform init` to migrate the backend to S3. Press `yes` when asked.

Now the regular CI/CD pipeline may be used to deploy remaining resources.
