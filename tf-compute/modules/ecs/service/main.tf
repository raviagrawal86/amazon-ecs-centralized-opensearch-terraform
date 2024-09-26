######################################################
# Cloudwatch log group to hold the firelens logs   ###
######################################################
resource "aws_cloudwatch_log_group" "firelens_logs" {
  name_prefix       = "/aws/ecs/app/${var.prefix}-firelens-logs-"
  retention_in_days = var.log_retention_period
  kms_key_id        = var.kms_key_id
  tags              = var.tags
}

###########################################
### Security Groups                     ###
###########################################
module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "app-sg-${var.prefix}-${var.service_name}"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.prefix}-${var.service_name} from ALB"

  ingress_with_source_security_group_id = [
    {
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      description              = "${var.prefix}-${var.service_name} SG"
      source_security_group_id = module.alb_sg.security_group_id
    },
  ]

  egress_rules = ["all-all"]

  tags = var.tags
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name        = "alb-sg-${var.prefix}-${var.service_name}"
  description = "Security Group for alb ${var.prefix}-${var.service_name}"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = local.ecs_config.alb_ingress_cidr_blocks
  ingress_rules       = ["https-443-tcp"]
  egress_rules        = ["all-all"]
}

###########################################
### ECS Resources                       ###
###########################################
module "firelens_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "0.60.1"
  container_name  = "log-router"
  container_image = var.aws_fluentbit_image
  firelens_configuration = {
    type = "fluentbit"
    options = {
      "enable-ecs-log-metadata" = "true"
    }
  }
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = aws_cloudwatch_log_group.firelens_logs.name
      "awslogs-region"        = data.aws_region.current.name
      "awslogs-create-group"  = "true"
      "awslogs-stream-prefix" = "firelens"
    }
  }
}

module "app_container_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "0.60.1"
  container_name  = "${var.prefix}-${var.service_name}"
  container_image = "${var.ecr_repository_url}:${var.ecr_image_tag}"
  port_mappings = [
    {
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }
  ]
  log_configuration = {
    logDriver = "awsfirelens"
    options = {
      "Name"               = "opensearch"
      "Match"              = "*"
      "Host"               = var.aoss_endpoint
      "Port"               = "443"
      "Index"              = var.prefix
      "Trace_Error"        = "On"
      "Trace_Output"       = "On"
      "AWS_Auth"           = "On"
      "AWS_Region"         = data.aws_region.current.name
      "AWS_Service_Name"   = "aoss"
      "AWS_Role_ARN"       = var.aoss_role_arn
      "tls"                = "On"
      "Suppress_Type_Name" = "On"
    }
  }
  map_secrets = {
    for param in data.aws_ssm_parameters_by_path.app.names : split("/", param)[2] => "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${param}"
  }
}

resource "aws_ecs_task_definition" "app" {
  #checkov:skip=CKV_AWS_249:There are no policies to be attached to ECS task
  family = "${var.prefix}-${var.service_name}"

  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs_config.ecs_task_cpu
  memory                   = local.ecs_config.ecs_task_memory

  container_definitions = jsonencode([
    module.firelens_definition.json_map_object,
    module.app_container_definition.json_map_object
  ])

  tags = var.tags
}


resource "aws_ecs_service" "service" {
  count = var.scheduled_task.enabled ? 0 : 1

  name    = "${var.prefix}-${var.service_name}"
  cluster = var.ecs_cluster_name

  task_definition                    = "${aws_ecs_task_definition.app.family}:${aws_ecs_task_definition.app.revision}"
  desired_count                      = local.ecs_config.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  deployment_maximum_percent         = local.ecs_config.deployment_maximum_percent
  deployment_minimum_healthy_percent = local.ecs_config.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [module.app_sg.security_group_id]
    assign_public_ip = local.ecs_config.assign_public_ip
  }

  load_balancer {
    container_name   = "${var.prefix}-${var.service_name}"
    container_port   = var.container_port
    target_group_arn = module.alb.target_groups["ex_ecs"].arn
  }


  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }
  deployment_controller {
    type = "ECS"
  }
  propagate_tags = "SERVICE"
  tags           = merge(var.tags, { Name = "${var.prefix}-service" })

  lifecycle {
    ignore_changes = [
      desired_count,
      # task_definition
    ]
  }
}

###########################################
### ALB                                 ###
###########################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.4.1"

  name     = "${var.prefix}-${var.service_name}"
  internal = false

  vpc_id          = var.vpc_id
  subnets         = var.private_subnets
  security_groups = [module.alb_sg.security_group_id]

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.route53_hosted_zone.acm_certificate_arn

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      name_prefix       = "h1"
      protocol          = "HTTP"
      port              = var.container_port
      target_type       = "ip"
      create_attachment = false
    }
  }

  tags = var.tags
}

resource "aws_route53_record" "app1_route53" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.route53_hosted_zone.service_fqdn
  type    = "CNAME"
  ttl     = "60"
  records = [module.alb.dns_name]
}


###########################################
### IAM                                 ###
###########################################
resource "aws_iam_role" "task_role" {
  name               = "${var.prefix}-${var.service_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}
