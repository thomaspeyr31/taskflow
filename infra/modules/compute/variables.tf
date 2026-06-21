variable "name" {
  description = "Prefix used to name all compute resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the ALB target group registers in."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets the ALB and ECS tasks live in."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group attached to the ALB."
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group attached to the ECS tasks."
  type        = string
}

variable "container_image" {
  description = "Container image (repository:tag) the task definition runs. Defaults to the ECR repo provisioned by this module — override from CI with the freshly built tag."
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port the application listens on inside the container."
  type        = number
  default     = 3000
}

variable "task_cpu" {
  description = "Fargate task CPU units. 256 = 0.25 vCPU (smallest Fargate size)."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB. Must match the CPU table (256 CPU -> 512 MiB minimum)."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS tasks to keep running."
  type        = number
  default     = 1
}

variable "db_endpoint" {
  description = "Hostname of the RDS instance, passed as DB_HOST to the container."
  type        = string
}

variable "db_port" {
  description = "Port of the RDS instance, passed as DB_PORT to the container."
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name, passed as DB_NAME to the container."
  type        = string
}

variable "db_username" {
  description = "Database username, passed as DB_USER to the container."
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the DB credentials JSON. The 'password' key is injected as DB_PASSWORD."
  type        = string
}

variable "log_retention_days" {
  description = "Retention for CloudWatch container logs."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
