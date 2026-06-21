terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region — must match the environments' region for state and resources."
  type        = string
  default     = "eu-west-3"
}

variable "github_owner" {
  description = "GitHub user or org that owns the repository (e.g. \"thomas-peyrusaubes\")."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (e.g. \"taskflow\")."
  type        = string
}

variable "state_bucket" {
  description = "Name of the S3 bucket holding the Terraform state. Must match backend.tf."
  type        = string
  default     = "taskflow-tfstate"
}

variable "state_lock_table" {
  description = "Name of the DynamoDB table used as Terraform state lock. Must match backend.tf."
  type        = string
  default     = "taskflow-tfstate-lock"
}

# OIDC provider: lets AWS trust signed tokens from GitHub Actions.
# Thumbprint is the SHA-1 fingerprint of the GitHub OIDC root CA, published by GitHub.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Trust policy: only this repo, and only branches/PRs (not arbitrary refs), can
# assume this role. The "sub" condition is the security gate — without it ANY
# repository could assume the role.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_owner}/${var.github_repo}:pull_request",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "taskflow-github-actions"
  description        = "Role assumed by GitHub Actions to build/deploy TaskFlow."
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

# Permissions granted to the CI role. Scoped to what the pipeline actually does:
# - manage Terraform state (S3 bucket + DynamoDB lock)
# - push images to ECR
# - read account info
# - manage the resources Terraform creates (broad enough but limited to project)
data "aws_iam_policy_document" "permissions" {
  # Terraform state in S3
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
    ]
    resources = ["arn:aws:s3:::${var.state_bucket}"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["arn:aws:s3:::${var.state_bucket}/*"]
  }

  # State lock
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]
    resources = ["arn:aws:dynamodb:*:*:table/${var.state_lock_table}"]
  }

  # ECR push (the build job needs this; Terraform doesn't push images itself)
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
    ]
    resources = ["*"]
  }

  # Force redeploys after a new image is pushed
  statement {
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeClusters",
    ]
    resources = ["*"]
  }

  # The CI role must be able to call iam:PassRole on the ECS execution/task
  # roles when registering new task definitions.
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  # Broad permissions for Terraform to manage the rest of the stack.
  # In a real production setup this would be scoped tighter — here it
  # allows the school project to iterate freely.
  statement {
    actions = [
      "ec2:*",
      "rds:*",
      "secretsmanager:*",
      "logs:*",
      "elasticloadbalancing:*",
      "iam:*",
      "ecr:*",
      "ecs:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "taskflow-github-actions-policy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.permissions.json
}

output "role_arn" {
  description = "ARN of the IAM role to set as AWS_ROLE_ARN in GitHub Actions secrets."
  value       = aws_iam_role.github_actions.arn
}
