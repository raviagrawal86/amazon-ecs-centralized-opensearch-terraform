# ECR Repo
resource "aws_ecr_repository" "aob_ui_ecr_repo" {
  #checkov:skip=CKV_AWS_136:Testing purposes
  name                 = "${var.prefix}/ui"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# ECR Lifecycle policy
resource "aws_ecr_lifecycle_policy" "foopolicy" {
  repository = aws_ecr_repository.aob_ui_ecr_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 2,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 1,
            "description": "Untagged images policy",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

# CodeBuild IAM Role
resource "aws_iam_role" "aob_ui_cb_role" {
  name = "${var.prefix}-ui-cb-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for CodeBuild Role
resource "aws_iam_role_policy" "aob_ui_cb_role_policy" {
  #checkov:skip=CKV_AWS_287:Testing purposes
  #checkov:skip=CKV_AWS_288:Testing purposes
  #checkov:skip=CKV_AWS_355:Testing purposes
  #checkov:skip=CKV_AWS_290:Testing purposes
  role = aws_iam_role.aob_ui_cb_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
           "codebuild:CreateReportGroup",
           "codebuild:CreateReport",
           "codebuild:UpdateReport",
           "codebuild:BatchPutTestCases",
           "codebuild:BatchPutCodeCoverages"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
           "ssm:DescribeParameters",
           "ssm:GetParameters"
        ],
        "Resource": "*"
    },
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    { 
      "Effect": "Allow",
      "Action": [
        "sts:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# CodeBuild Project
resource "aws_codebuild_project" "aob_ui_codebuild_project" {
  #checkov:skip=CKV_AWS_316:Testing purposes
  name         = "${var.prefix}-ui-project-build"
  description  = "Build Project for ${var.prefix} ui deployment"
  service_role = aws_iam_role.aob_ui_cb_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    privileged_mode = true
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type            = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "ECR_REPO_NAME"
      value = aws_ecr_repository.aob_ui_ecr_repo.name
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/codebuild/${var.prefix}/ui"
      stream_name = "codebuild-log-stream"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/raviagrawal86/aspnet-demo-application.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = "main"

  tags = {
    Environment = "Dev"
  }
}

# Webhook to trigger CodeBuild whenever a new tag is pushed
resource "aws_codebuild_webhook" "aob_ui_codebuild_webhook" {
  project_name = aws_codebuild_project.aob_ui_codebuild_project.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "^refs/tags/.*"
    }
  }
}
