# Learning Log

This log captures daily updates for cloud security experiments. Notes on detection and attack techniques are organized within each service directory.

## 2025-06-07 – Day 1: Amazon ECR

### Key Features

- Fully managed container registry supporting OCI images
- Public and private repositories with high durability
- Lifecycle policies to prune old or unused images
- Supports tagging strategies for region or stage
- Access control via IAM policies and repository resource policies
- Basic scanning with Clair and enhanced scanning via Amazon Inspector
- Audit actions through CloudTrail

### Authentication

```bash
aws ecr get-login-password --region us-west-2 | \
  docker login --username AWS --password-stdin <repo-url>
```

Alternatively you can call the token directly via cURL:

```bash
curl -i -H "Authorization: Basic $TOKEN" https://<account-id>.dkr.ecr.<region>.amazonaws.com
```

### Labs Completed

- Created an IAM user for CLI access via Terraform
- Provisioned QA and production ECR repositories with different policies
- Verified policy enforcement by attempting unauthorized pushes
- Enabled enhanced scanning and inspected findings using:
  - `aws ecr describe-images --repository-name <repo>`
  - `aws ecr describe-image-scan-findings --repository-name <repo> --image-id imageDigest=<digest>`
- Built a Terraform module to configure registry scanning

```terraform
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
```

### Topics Covered

- IAM vs repository-based access policies
- Container image scanning and Inspector integration
- Docker login and AWS token authentication
- Terraform automation for registry provisioning

### Experiments & Ideas

See [AWS/ECR/notes/ideas.md](AWS/ECR/notes/ideas.md) for a list of future experiments and next steps.
See [AWS/ECR/notes/ecr-monitoring.md](AWS/ECR/notes/ecr-monitoring.md) for CloudTrail monitoring and Athena queries.

#### Immutable Tags

To ensure images are never overwritten, ECR supports immutable tags. Once enabled, pushing a tag that already exists results in an error.

```terraform
resource "aws_ecr_repository" "example" {
  name                 = "example"
  image_tag_mutability = "IMMUTABLE"
}
```

This can also be configured through the AWS CLI:

```bash
aws ecr put-image-tag-mutability \
  --repository-name example \
  --image-tag-mutability IMMUTABLE
```


## 2025-06-08 – Day 2: Logging and Monitoring

### Tag Immutability
- Enabled immutable tags through Terraform and verified enforcement with the AWS CLI.

### CloudTrail Logging
- Configured a trail to capture ECR actions for auditing. Steps documented in [AWS/ECR/notes/ecr-monitoring.md](AWS/ECR/notes/ecr-monitoring.md).

### Athena Queries
- Created a table over the CloudTrail bucket and executed:

```sql
SELECT eventTime, eventName, userIdentity.userName
FROM ecr_cloudtrail_logs
WHERE eventSource = 'ecr.amazonaws.com'
ORDER BY eventTime DESC
LIMIT 50;
```

### EventBridge Integration
- Added rules to notify on image pushes. Details in [AWS/ECR/notes/eventbridge.md](AWS/ECR/notes/eventbridge.md).

### Image Scanning Audit
- Wrote a Python script to report critical scan findings. See [AWS/ECR/scripts/scan_audit.py](AWS/ECR/scripts/scan_audit.py) and [AWS/ECR/notes/scan-audit.md](AWS/ECR/notes/scan-audit.md).
