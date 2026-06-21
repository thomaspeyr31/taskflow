#!/usr/bin/env bash
set -euo pipefail

BUCKET="${BUCKET:-taskflow-tfstate}"
TABLE="${TABLE:-taskflow-tfstate-lock}"
REGION="${AWS_REGION:-eu-west-3}"

echo "WARNING: this will delete the Terraform state backend."
echo "Make sure 'terraform destroy' has already been run on every environment."
read -rp "Continue? (yes/no) " ack
[[ "${ack}" == "yes" ]] || { echo "Aborted."; exit 1; }

echo "Emptying s3://${BUCKET} (all versions)"
aws s3api list-object-versions --bucket "${BUCKET}" \
  --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
  --output json | aws s3api delete-objects --bucket "${BUCKET}" --delete file:///dev/stdin || true

aws s3api list-object-versions --bucket "${BUCKET}" \
  --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
  --output json | aws s3api delete-objects --bucket "${BUCKET}" --delete file:///dev/stdin || true

echo "Deleting bucket s3://${BUCKET}"
aws s3api delete-bucket --bucket "${BUCKET}" --region "${REGION}"

echo "Deleting DynamoDB table ${TABLE}"
aws dynamodb delete-table --table-name "${TABLE}" --region "${REGION}" >/dev/null
aws dynamodb wait table-not-exists --table-name "${TABLE}" --region "${REGION}"

echo "Done."
