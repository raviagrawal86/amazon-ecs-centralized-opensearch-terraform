data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_ssm_parameters_by_path" "app" {
  path            = "/${var.prefix}"
  with_decryption = false
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_route53_zone" "selected" {
  name         = "${var.route53_hosted_zone.hosted_zone_name}."
  private_zone = var.route53_hosted_zone.private_hosted_zone
}
