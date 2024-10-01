###############################################################################################################
########################################## Shared Services Account Resources  #################################
###############################################################################################################

###########################################
### AOSS Cross Account Role             ###
###########################################
resource "aws_iam_role" "aoss_cross_account_role" {
  provider           = aws.shared_services_account
  name               = local.aoss_cross_account_role_name
  assume_role_policy = data.aws_iam_policy_document.aoss_assume_role_policy.json
}

resource "aws_iam_role_policy" "aoss_cross_account_role_permission" {
  provider = aws.shared_services_account
  name     = "${var.prefix}-aoss-role-policy"
  role     = aws_iam_role.aoss_cross_account_role.id
  policy   = data.aws_iam_policy_document.aoss_permissions_policy.json
}

###########################################
### AOSS Policies                       ###
###########################################
# Creates a network policy
resource "aws_opensearchserverless_security_policy" "network_policy" {
  provider    = aws.shared_services_account
  name        = var.prefix
  type        = "network"
  description = "public access for dashboard, VPC access for ${local.aoss_collection_name} endpoint"
  policy      = jsonencode(local.aoss_network_policy)
}

# Creates a data access policy
resource "aws_opensearchserverless_access_policy" "data_access_policy" {
  provider    = aws.shared_services_account
  name        = var.prefix
  type        = "data"
  description = "allow index and collection access"
  policy      = jsonencode(local.aoss_data_access_policy)
}

###############################################################################################################
##########################################      Compute Account Resources      ################################
###############################################################################################################

###########################################
### AOSS VPC Endpoint                   ###
###########################################
# # Creates a VPC endpoint
resource "aws_opensearchserverless_vpc_endpoint" "vpc_endpoint" {
  name               = "${var.prefix}-aoss"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.vpce_security_group.id]
}

# Creates a security group to be attached to VPCe
resource "aws_security_group" "vpce_security_group" {
  #checkov:skip=CKV2_AWS_5:The AOSS security group allows CIDR ingress and is attached to AOSS
  description = "Security group for ${var.prefix}-aoss"
  vpc_id      = module.vpc.vpc_id

  # Allow all egress access
  egress {
    description = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# Create an ingress rule for each ECS task
# so they all can write to AOSS for logging
resource "aws_vpc_security_group_ingress_rule" "vpce_security_group" {
  for_each                     = var.ecs_applications
  description                  = "Security group for ${var.prefix}-aoss for application ${each.key}"
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.vpce_security_group.id
  referenced_security_group_id = module.ecs_service[each.key].security_group_id
}

###########################################
### KMS Creation                        ###
###########################################
module "kms" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=fe1beca2118c0cb528526e022a53381535bb93cd"

  aliases               = ["terraform/${var.prefix}"]
  description           = "${var.prefix} application kms key"
  enable_default_policy = true
  key_statements        = local.kms_cloudwatch_access

  tags = local.tags
}

###########################################
### ECS Cluster & task execution role   ###
###########################################
module "ecs_cluster" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/cluster?ref=9a8c7d3cb799ec297d8ae1891616bc2872799ab7"

  cluster_name = var.prefix

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${var.prefix}"
      }
    }
  }

  # Capacity providers, weight should sum to 100
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  # Create task execution role as part of cluster and
  # allow it to assume AOSS cross account role
  create_task_exec_iam_role = true
  task_exec_iam_role_name   = local.task_exec_iam_role_name
  task_exec_iam_role_policies = {
    aoss = aws_iam_policy.ecs_task_exec_permissions.arn
  }

  tags = local.tags
}

# Managed IAM policy that allows ECS task execution role
# to assume AOSS cross account role in shared services account
resource "aws_iam_policy" "ecs_task_exec_permissions" {
  name        = "AOSS-Cross-Account-Role-Assume"
  path        = "/"
  description = "This policy allows ECS Task execution role to assume AOSS cross account role to write to AOSS"
  policy      = data.aws_iam_policy_document.ecs_task_exec_permissions.json
}

###########################################
### ECSService                          ###
###########################################
module "ecs_service" {
  for_each = var.ecs_applications
  source   = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service?ref=9a8c7d3cb799ec297d8ae1891616bc2872799ab7"

  name        = "${var.prefix}-${each.key}"
  cluster_arn = module.ecs_cluster.arn

  # Container definition(s)
  container_definitions = {
    # 1. Firelens container - runs as a sidecar and ships logs over to AOSS
    fluent-bit = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = var.aws_fluentbit_image
      firelens_configuration = {
        type = "fluentbit"
      }
      memory_reservation = 50
    }

    # 2. Application container - actual application container
    (local.container_name) = {
      cpu       = each.value.cpu
      memory    = each.value.memory
      essential = true
      image     = each.value.image
      port_mappings = [
        {
          name          = each.key
          containerPort = each.value.container_port
          hostPort      = each.value.container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      dependencies = [{
        containerName = "fluent-bit"
        condition     = "START"
      }]

      enable_cloudwatch_logging = false
      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          "Name"               = "opensearch"
          "Match"              = "*"
          "Host"               = trimprefix(data.aws_opensearchserverless_collection.aoss_logging.collection_endpoint, "https://")
          "Port"               = "443"
          "Index"              = "${var.prefix}-${each.key}"
          "Trace_Error"        = "On"
          "Trace_Output"       = "On"
          "AWS_Auth"           = "On"
          "AWS_Region"         = var.aws_region
          "AWS_Service_Name"   = "aoss"
          "AWS_Role_ARN"       = aws_iam_role.aoss_cross_account_role.arn
          "tls"                = "On"
          "Suppress_Type_Name" = "On"
        }
      }
      memory_reservation = 100
    }
  }

  # Do not create the role again, instead use what we created
  # in the ecs_cluster module
  create_tasks_iam_role     = false
  create_task_exec_iam_role = false
  tasks_iam_role_arn        = module.ecs_cluster.task_exec_iam_role_arn
  task_exec_iam_role_arn    = module.ecs_cluster.task_exec_iam_role_arn

  # Attach the load balancer
  load_balancer = {
    service = {
      target_group_arn = module.alb[each.key].target_groups["ex_ecs"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  # Security group for the task
  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    # Allow inbound traffic from the ALB security group over TCP 443
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb[each.key].security_group_id
    }
    # Allow all egress traffic
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.tags
}

###########################################
### Supporting Resources                ###
###########################################
module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=e226cc15a7b8f62fd0e108792fea66fa85bcb4b9"

  name = var.prefix
  cidr = var.primary_cidr
  azs  = local.azs

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.prefix}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.prefix}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.prefix}-default" }

  tags = local.tags
}

module "alb" {
  for_each = var.ecs_applications
  source   = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=454d2cbf78d48b9eaeb499bfe6dd05fe30b4ae0c"

  name = var.prefix

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.vpc.default_security_group_id]

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex_ecs"
      }
    }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = each.value.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = local.tags
}
