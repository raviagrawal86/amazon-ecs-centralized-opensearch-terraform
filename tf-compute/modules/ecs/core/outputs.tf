output "ecs_cluster_arn" {
  value       = module.ecs.cluster_arn
  description = "ARN that identifies the cluster"
}

output "ecs_cluster_id" {
  value       = module.ecs.cluster_id
  description = "ID that identifies the cluster"
}

output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
  description = "Name that identifies the cluster"
}

output "ecs_cluster_capacity_providers" {
  value       = module.ecs.cluster_capacity_providers
  description = "Map of cluster capacity providers attributes"
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution.arn
  description = "ECS task execution role ARN."
}

output "ecs_task_execution_role_name" {
  value       = aws_iam_role.ecs_task_execution.name
  description = "ECS task execution role name."
}