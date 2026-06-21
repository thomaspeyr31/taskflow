output "endpoint" {
  description = "Hostname (without port) of the RDS instance."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "TCP port the RDS instance listens on."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the initial database."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username."
  value       = var.db_username
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master credentials. Granted to the ECS task execution role."
  value       = aws_secretsmanager_secret.db.arn
}
