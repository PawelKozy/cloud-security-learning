# ECR Scan Audit Lambda

This note describes a simple Lambda function to report images with critical vulnerabilities.

The accompanying [scan_audit.py](../scripts/scan_audit.py) script lists repositories, retrieves image scan findings, and prints an alert if any critical vulnerabilities are found. It can be packaged as a Lambda function and triggered daily via EventBridge.

Key steps:
1. Grant the function `ecr:DescribeRepositories`, `ecr:ListImages`, and `ecr:DescribeImageScanFindings` permissions.
2. Schedule it with an EventBridge rule or run it via cron.
3. Extend the script to send results to SNS or Slack.
