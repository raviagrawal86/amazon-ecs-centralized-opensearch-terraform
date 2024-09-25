# # CodePipeline Resource
# resource "aws_codepipeline" "codepipeline" {
#   name     = "${var.prefix}-Pipeline"
#   role_arn = aws_iam_role.codepipeline_role.arn

#   artifact_store {
#     location = aws_s3_bucket.codepipeline_bucket.bucket
#     type     = "S3"

#     encryption_key {
#       id   = data.aws_kms_alias.s3kmskey.arn
#       type = "KMS"
#     }
#   }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "S3"
#       version          = "1"
#       output_artifacts = ["source_output"]

#       configuration = {
#         S3Bucket = "bayer-iac-temp-bucket"
#         S3ObjectKey = "terraform.zip"
#         PollForSourceChanges = "${var.poll-source-changes}"
#       }
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       name             = "Build"
#       category         = "Build"
#       owner            = "AWS"
#       provider         = "CodeBuild"
#       input_artifacts  = ["source_output"]
#       output_artifacts = ["build_output"]
#       version          = "1"

#       configuration = {
#         ProjectName = "${var.prefix}-iac-project-build"
#       }
#     }
#   }

# }

# # CodePipeline IAM role
# resource "aws_iam_role" "codepipeline_role" {
#   name = "${var.prefix}-iac-codepipeline-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codepipeline.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# # S3 bucket for codepipeline
# resource "aws_s3_bucket" "codepipeline_bucket" {
#   bucket = "${var.prefix}-codepipeline-s3-bucket-109972344243"
# }

# # Code Pipeline S3 bucket ACL
# resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket_ownership" {
#   bucket = aws_s3_bucket.codepipeline_bucket.id

#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# # Code Pipeline IAM role policy
# resource "aws_iam_role_policy" "codepipeline_policy" {
#   name = "codepipeline_policy"
#   role = aws_iam_role.codepipeline_role.id

#   policy = <<EOF
# {
#     "Statement": [
#         {
#             "Action": [
#                 "iam:PassRole"
#             ],
#             "Resource": "*",
#             "Effect": "Allow",
#             "Condition": {
#                 "StringEqualsIfExists": {
#                     "iam:PassedToService": [
#                         "cloudformation.amazonaws.com",
#                         "elasticbeanstalk.amazonaws.com",
#                         "ec2.amazonaws.com",
#                         "ecs-tasks.amazonaws.com"
#                     ]
#                 }
#             }
#         },
#         {
#             "Action": [
#                 "codecommit:CancelUploadArchive",
#                 "codecommit:GetBranch",
#                 "codecommit:GetCommit",
#                 "codecommit:GetRepository",
#                 "codecommit:GetUploadArchiveStatus",
#                 "codecommit:UploadArchive"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "codedeploy:CreateDeployment",
#                 "codedeploy:GetApplication",
#                 "codedeploy:GetApplicationRevision",
#                 "codedeploy:GetDeployment",
#                 "codedeploy:GetDeploymentConfig",
#                 "codedeploy:RegisterApplicationRevision"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "codestar-connections:UseConnection"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "elasticbeanstalk:*",
#                 "ec2:*",
#                 "elasticloadbalancing:*",
#                 "autoscaling:*",
#                 "cloudwatch:*",
#                 "s3:*",
#                 "sns:*",
#                 "cloudformation:*",
#                 "rds:*",
#                 "sqs:*",
#                 "ecs:*"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "lambda:InvokeFunction",
#                 "lambda:ListFunctions"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "opsworks:CreateDeployment",
#                 "opsworks:DescribeApps",
#                 "opsworks:DescribeCommands",
#                 "opsworks:DescribeDeployments",
#                 "opsworks:DescribeInstances",
#                 "opsworks:DescribeStacks",
#                 "opsworks:UpdateApp",
#                 "opsworks:UpdateStack"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "cloudformation:CreateStack",
#                 "cloudformation:DeleteStack",
#                 "cloudformation:DescribeStacks",
#                 "cloudformation:UpdateStack",
#                 "cloudformation:CreateChangeSet",
#                 "cloudformation:DeleteChangeSet",
#                 "cloudformation:DescribeChangeSet",
#                 "cloudformation:ExecuteChangeSet",
#                 "cloudformation:SetStackPolicy",
#                 "cloudformation:ValidateTemplate"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Action": [
#                 "codebuild:BatchGetBuilds",
#                 "codebuild:StartBuild",
#                 "codebuild:BatchGetBuildBatches",
#                 "codebuild:StartBuildBatch"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "devicefarm:ListProjects",
#                 "devicefarm:ListDevicePools",
#                 "devicefarm:GetRun",
#                 "devicefarm:GetUpload",
#                 "devicefarm:CreateUpload",
#                 "devicefarm:ScheduleRun"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "servicecatalog:ListProvisioningArtifacts",
#                 "servicecatalog:CreateProvisioningArtifact",
#                 "servicecatalog:DescribeProvisioningArtifact",
#                 "servicecatalog:DeleteProvisioningArtifact",
#                 "servicecatalog:UpdateProduct"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "cloudformation:ValidateTemplate"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ecr:DescribeImages"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "states:DescribeExecution",
#                 "states:DescribeStateMachine",
#                 "states:StartExecution"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "appconfig:StartDeployment",
#                 "appconfig:StopDeployment",
#                 "appconfig:GetDeployment"
#             ],
#             "Resource": "*"
#         }
#     ],
#     "Version": "2012-10-17"
# }
# EOF
# }

# # S3 KMS key
# data "aws_kms_alias" "s3kmskey" {
#   name = "alias/aws/s3"
# }
