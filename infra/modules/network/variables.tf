variable "name" {
  description = "Prefix used to name all networking resources (e.g. \"taskflow-dev\")."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones to spread subnets across. At least 2 are required because RDS demands a multi-AZ subnet group."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ). Hosts the ECS tasks (no NAT setup)."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per AZ). Hosts the RDS instance."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "container_port" {
  description = "Port the application container listens on. Used to scope the ECS security group."
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "Port the database listens on. Used to scope the RDS security group."
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Tags applied to every resource created by the module."
  type        = map(string)
  default     = {}
}
