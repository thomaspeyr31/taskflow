# Bootstrap CI — GitHub OIDC role

One-time setup to let GitHub Actions assume an AWS role without storing any
long-lived credentials.

## What this creates

- An IAM **OIDC identity provider** pointing at `token.actions.githubusercontent.com`.
- An IAM **role** (`taskflow-github-actions`) with a trust policy that only
  accepts tokens coming from this exact repo (`<owner>/<repo>`) on the `main`
  branch or on pull requests.
- An inline policy on the role granting just what the pipeline needs:
  Terraform state (S3 + DynamoDB), ECR push, ECS update, and the AWS resources
  the modules manage.

## Run it

After the main backend bootstrap has been done:

```bash
cd infra/bootstrap-ci
terraform init   # local state — this is bootstrap, no backend
terraform apply -var="github_owner=<your-gh-username-or-org>" -var="github_repo=taskflow"
```

Copy the `role_arn` output into a GitHub repository variable named
`AWS_ROLE_ARN` (Settings → Secrets and variables → Actions → Variables).

## Why is this not in `environments/dev/`?

Because the OIDC role is what the CI uses to manage `environments/dev/`. If
it were managed from there, the CI couldn't bootstrap itself (chicken and egg).
