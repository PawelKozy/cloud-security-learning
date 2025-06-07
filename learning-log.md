# Learning Log

This file will record daily updates about my cloud security experiments. As scripts are added under directories such as `Security-Automation` and `micro-projects`, they will be referenced here for quick access.

2025-06-07 – Day 1: Amazon ECR

🔍 Key Features

Amazon ECR is a fully managed container registry supporting OCI-compliant image storage.

Offers public and private repositories.

Highly available and durable by design.

Integrates with lifecycle policies to automatically remove old/unused images.

Supports tagging for managing regional differences or lifecycle stages.

Fine-grained access via IAM policies and repository-based resource policies (e.g., cross-account access).

Security scanning:

Basic scanning with Clair.

Enhanced scanning with Amazon Inspector, with alerts routed via EventBridge.

Auditability through CloudTrail events for ECR actions.

🔐 Authentication

aws ecr get-login-password provides a 12-hour token for Docker login:

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <repo-url>

Can also use token via HTTP:

curl -i -H "Authorization: Basic $TOKEN" https://<account-id>.dkr.ecr.<region>.amazonaws.com

🧪 Labs Completed

IAM User Setup: Created IAM user with CLI access using Terraform (aws_iam_user, aws_iam_access_key, aws_iam_user_policy).

ECR Repositories:

Created two ECR repositories with different policies (QA and Prod).

Validated policy enforcement by attempting to push to the wrong repo.

Vulnerability Scanning:

Enabled enhanced scanning for repos.

Used aws ecr describe-image-scan-findings to fetch results.

aws ecr describe-images --repository-name <repo>
aws ecr describe-image-scan-findings --repository-name <repo> --image-id imageDigest=<digest>

Terraform Practice: Built end-to-end provisioning using random_string, aws_ecr_repository, and scanning configuration:

resource "aws_ecr_registry_scanning_configuration" "test" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "*"
      filter_type = "WILDCARD"
    }
  }

  rule {
    scan_frequency = "CONTINUOUS_SCAN"
    repository_filter {
      filter      = "example"
      filter_type = "WILDCARD"
    }
  }
}

📌 Topics Covered

ECR access policies: IAM vs repository-based

Container image scanning and Inspector integration

Docker login and AWS token auth

Terraform automation for registry provisioning

⚙️ Experiments & Ideas

Try uploading images with critical CVEs and test event notifications.

Explore lifecycle_policy to auto-delete old images based on tags.

Compare scan coverage: Clair vs Amazon Inspector.

🔜 Next Steps

Implement push pipeline to ECR from local Docker.

Explore repository replication across regions.

Continue into IAM fine-tuning for repo-specific access.

Begin container security configuration (runtime, secrets, etc.)