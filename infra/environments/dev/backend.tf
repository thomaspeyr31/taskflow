terraform {
  # State is stored in S3 (encrypted, versioned) and locked through DynamoDB.
  # The bucket and table must be created out-of-band (one-shot bootstrap) before
  # the first `terraform init` because Terraform cannot manage its own backend.
  # See infra/bootstrap/README.md for the create-once commands.
  backend "s3" {
    bucket         = "taskflow-tfstate"
    key            = "environments/dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "taskflow-tfstate-lock"
    encrypt        = true
  }
}
