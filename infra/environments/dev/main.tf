terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  name = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  name = local.name
  azs  = var.availability_zones
  tags = local.common_tags
}

module "database" {
  source = "../../modules/database"

  name                   = local.name
  subnet_ids             = module.network.private_subnet_ids
  vpc_security_group_ids = [module.network.rds_security_group_id]
  tags                   = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  name                  = local.name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
  ecs_security_group_id = module.network.ecs_security_group_id

  container_image = var.container_image

  db_endpoint   = module.database.endpoint
  db_port       = module.database.port
  db_name       = module.database.db_name
  db_username   = module.database.db_username
  db_secret_arn = module.database.secret_arn

  tags = local.common_tags
}
