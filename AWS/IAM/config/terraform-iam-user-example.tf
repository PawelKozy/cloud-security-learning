provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "example_user" {
  name = "example-user"
  path = "/system/"
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-iam-bucket-${random_id.suffix.hex}"
  force_destroy = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "AllowS3ListBucket"
  description = "Allow listing the contents of the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Resource = [
          aws_s3_bucket.example_bucket.arn,
          "${aws_s3_bucket.example_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "example_attachment" {
  user       = aws_iam_user.example_user.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_access_key" "user_creds" {
  user = aws_iam_user.example_user.name
}

output "access_key_id" {
  value       = aws_iam_access_key.user_creds.id
  description = "User access key ID"
  sensitive   = true
}

output "secret_access_key" {
  value       = aws_iam_access_key.user_creds.secret
  description = "User secret access key"
  sensitive   = true
}
