# output "alb_dns" {
#   value = module.ecs_service_app[*].alb_dns
# }

output "services" {
  value = module.ecs_service_app
}