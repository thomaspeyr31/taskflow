variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
  default     = "eu-west-3"
}

variable "project" {
  description = "Project name used as a prefix for every resource."
  type        = string
  default     = "taskflow"
}

variable "environment" {
  description = "Environment name (dev, staging, prod...). Combined with `project` to scope resources."
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  description = "AZs to spread subnets across. Must contain at least 2 entries."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "container_image" {
  description = "Container image (repository:tag) for the API. Leave empty to fall back to <ecr>:latest — CI overrides this with the commit-tagged image."
  type        = string
  default     = ""
}
