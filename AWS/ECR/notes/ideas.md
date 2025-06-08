# ECR Experiment Ideas

These notes capture experiments and potential follow-up tasks for improving Amazon ECR usage.

## Experiments

- Push images that contain critical CVEs and verify Inspector alerts via EventBridge.
- Test lifecycle policies to automatically remove old tags after 30 days.
- Compare basic Clair scanning results with enhanced Inspector scanning.

## Next Steps

- Build a push pipeline from local Docker to ECR.
- Evaluate repository replication across regions for high availability.
- Tighten IAM permissions for repository-specific roles.
- Plan container runtime security controls and secrets management.
- Enable immutable tags so CI/CD pipelines can't inadvertently replace released images.

