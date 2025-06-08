#!/usr/bin/env python3
"""Simple script to report critical ECR scan findings.

This can run as a scheduled Lambda or cron job.
"""
import boto3
from botocore.exceptions import ClientError

REGION = boto3.session.Session().region_name or "us-west-2"
ECR = boto3.client("ecr", region_name=REGION)


def check_repositories():
    repos = ECR.describe_repositories()["repositories"]
    for repo in repos:
        name = repo["repositoryName"]
        try:
            images = ECR.list_images(repositoryName=name, filter={"tagStatus": "TAGGED"})["imageIds"]
        except ClientError as exc:
            print(f"Failed to list images for {name}: {exc}")
            continue
        for image in images:
            try:
                result = ECR.describe_image_scan_findings(repositoryName=name, imageId=image)
            except ClientError as exc:
                # Skip images without findings
                if exc.response["Error"]["Code"] == "ScanNotFoundException":
                    continue
                print(f"Error retrieving findings for {name}:{image}: {exc}")
                continue
            findings = result.get("imageScanFindings", {}).get("findingSeverityCounts", {})
            if findings.get("CRITICAL", 0) > 0:
                digest = image.get("imageDigest")
                print(f"CRITICAL findings detected in {name}@{digest}")


def main():
    check_repositories()


if __name__ == "__main__":
    main()
