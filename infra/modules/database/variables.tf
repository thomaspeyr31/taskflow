variable "name" {
  description = "Prefix used to name the RDS instance, subnet group and secret."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs the RDS instance will live in. At least 2 subnets in distinct AZs are required."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security groups attached to the RDS instance. Should restrict 5432 to the ECS tasks security group."
  type        = list(string)
}

variable "db_name" {
  description = "Initial database name created on the instance."
  type        = string
  default     = "taskflow"
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "taskflow"
}

variable "engine_version" {
  description = "PostgreSQL engine version to provision."
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "RDS instance class. t3.micro is eligible for the free tier."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
