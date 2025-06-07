# Example Terraform configuration for an ECR repository with scanning and lifecycle policy

resource "aws_ecr_repository" "sample" {
  name                 = "example-repo"
  image_tag_mutability = "MUTABLE"

  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description  = "Expire untagged images after 14 days"
          selection    = {
            tagStatus   = "untagged"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = 14
          }
          action = { type = "expire" }
        }
      ]
    })
  }
}

resource "aws_ecr_registry_scanning_configuration" "example" {
  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "example-repo"
      filter_type = "WILDCARD"
    }
  }
}
