#!/bin/bash
# Simple helper to build and push a Docker image to an ECR repository.
# Usage: ./push_to_ecr.sh <repository> <tag>

set -euo pipefail

REPO="$1"
TAG="${2:-latest}"
AWS_REGION=${AWS_REGION:-us-west-2}

# Authenticate Docker to ECR
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.$AWS_REGION.amazonaws.com"

# Build and push
IMAGE="$REPO:$TAG"
docker build -t "$IMAGE" .

docker push "$IMAGE"

echo "Pushed $IMAGE"
