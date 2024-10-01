prefix                                        = "aoss-logging"
aws_region                                    = "us-east-1"
terraform_shared_services_deploy_iam_role_arn = "arn:aws:iam::747273909328:role/aoss-logging-109972344243-terraform-deployment-role"
primary_cidr                                  = "10.0.0.0/24"
ecs_applications = {
  ecsdemo = {
    image          = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
    container_port = 3000
    cpu            = 512
    memory         = 1024
    desired_count  = 2
  }
}
