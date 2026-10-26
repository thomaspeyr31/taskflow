# Security

This project is a learning vehicle for a secure AWS delivery pipeline. This page
describes what is checked automatically, what is knowingly accepted in the `dev`
environment, and how to report a problem.

## Automated controls

Every push and pull request to `main` runs these checks in
[`pipeline.yml`](.github/workflows/pipeline.yml). Nothing is built or deployed
if one of them fails.

| Control | Tool | Blocks the pipeline when |
|---------|------|--------------------------|
| Dependency audit | `npm audit` | a production dependency has a high or critical advisory |
| Infrastructure-as-Code scan | Checkov (pinned version) | the Terraform code introduces a misconfiguration that is not in the reviewed baseline |
| Container image scan | Trivy | the image has a HIGH or CRITICAL vulnerability that already has a fix |
| Cloud access | GitHub OIDC | — no long-lived AWS keys exist; only `main` and pull requests of this repository can assume the CI role |

Dependabot opens weekly update pull requests for npm packages, the Docker base
image and GitHub Actions; each one goes through the same checks.

The full Checkov report, including accepted findings, is published to the
repository's **Security → Code scanning** tab on every run.

## Accepted risks (dev environment)

The existing findings were reviewed and recorded in
[`infra/.checkov.baseline`](infra/.checkov.baseline). They are accepted for a
short-lived, low-cost `dev` environment that holds no real data. Each one has a
known remediation for a production environment.

| Area | Accepted in `dev` | Why | Production remediation |
|------|-------------------|-----|------------------------|
| Transport | ALB listens on HTTP only, no WAF | No domain or certificate for a throwaway environment | ACM certificate, HTTPS listener with TLS 1.2+, HTTP→HTTPS redirect, AWS WAF |
| Network | ECS tasks run in public subnets with a public IP | Avoids the cost of a NAT gateway; inbound traffic is still limited to the ALB by security group | Private subnets with NAT gateway or VPC endpoints |
| CI permissions | The deploy role has broad service permissions on `*` | Terraform must create IAM, network and compute resources; the role can only be assumed from this repository | Scope actions to project ARNs or tags and add an IAM permissions boundary |
| Images | ECR tags are mutable | The pipeline moves a `latest` pointer; deployments always use the immutable commit-SHA tag | Immutable tags, deploy by digest |
| Encryption | AWS-managed keys instead of customer-managed KMS keys (ECR, CloudWatch Logs, Secrets Manager) | Data is encrypted at rest; a CMK adds cost and key management | Customer-managed KMS keys with rotation |
| Logging and monitoring | No VPC flow logs, ALB access logs, RDS logs, Performance Insights or Container Insights; short log retention | Cost in `dev` | Enable them and keep logs for at least one year |
| Database resilience | Single-AZ RDS, no deletion protection, no IAM authentication, no automatic secret rotation | The environment is destroyed and recreated at will | Multi-AZ, deletion protection, IAM auth, Secrets Manager rotation |

## Updating the baseline

Any finding that is not in the baseline fails the pipeline. Fix it in the
Terraform code whenever possible. If a new finding must be accepted, record it
deliberately and document it in the table above:

```bash
pip install checkov==3.3.30
checkov -d infra --framework terraform --create-baseline
```

Review the diff of `infra/.checkov.baseline` in the pull request.

## Reporting a vulnerability

Please do not open a public issue. Use GitHub's
[private vulnerability reporting](https://github.com/thomaspeyr31/taskflow/security/advisories/new) or email
thomassspe@gmail.com.
