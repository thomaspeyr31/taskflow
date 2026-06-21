output "alb_dns_name" {
  description = "Public DNS to reach the API (http://<this>/tasks)."
  value       = module.compute.alb_dns_name
}

output "ecr_repository_url" {
  description = "ECR URL — CI pushes images here."
  value       = module.compute.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name (consumed by CI for redeploys)."
  value       = module.compute.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name (consumed by CI for redeploys)."
  value       = module.compute.ecs_service_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN holding the DB credentials JSON."
  value       = module.database.secret_arn
}
