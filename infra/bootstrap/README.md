# Bootstrap — remote state backend

Terraform cannot manage the bucket and table that store its own state (chicken
and egg). Run the script below **once per AWS account** before the first
`terraform init` on any environment.

## What this creates

| Resource | Purpose |
|---|---|
| `s3://taskflow-tfstate` | Holds `.tfstate` files (encrypted, versioned, public access blocked). |
| DynamoDB `taskflow-tfstate-lock` | Prevents concurrent `terraform apply` (state lock). |

## Run it

```bash
# region must match backend.tf
export AWS_REGION=eu-west-3
./create-backend.sh
```

## Tear it down (last step, after `terraform destroy`)

```bash
./destroy-backend.sh
```

Be careful — the bucket has versioning on, so `aws s3 rb` requires `--force`
and will refuse if any object versions remain. The destroy script handles that.
