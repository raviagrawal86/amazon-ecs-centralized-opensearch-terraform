locals {
  ecs_config = merge(
    {
      ecs_task_cpu                       = 256
      ecs_task_memory                    = 512
      desired_count                      = 1
      deployment_maximum_percent         = 200
      deployment_minimum_healthy_percent = 100
      assign_public_ip                   = false
      cloudwatch_log_retention_in_days   = 7
      alb_ingress_cidr_blocks            = ["0.0.0.0/0"]
    },
    var.ecs_overwrites
  )
}