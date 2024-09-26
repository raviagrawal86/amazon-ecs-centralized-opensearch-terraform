output "ecs_service_name" {
  value = aws_ecs_service.service[0].name
}

output "alb_dns" {
  value = module.alb.dns_name
}

output "app_security_group" {
  value = module.app_sg.security_group_id
}
