output "alb_dns_name" {
  description = "DNS name of the ALB — entry point for the API."
  value       = aws_lb.this.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository the CI pushes images to."
  value       = aws_ecr_repository.this.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster (used by CI to trigger redeploys)."
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service (used by CI to trigger redeploys)."
  value       = aws_ecs_service.this.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group containing container logs."
  value       = aws_cloudwatch_log_group.this.name
}
