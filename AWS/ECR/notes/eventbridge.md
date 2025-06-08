# EventBridge Rules for ECR Events

This note outlines how to trigger notifications or Lambda functions based on Amazon ECR activity.

## CLI Example: Alert on Image Push

Create a rule that captures `PutImage` events and forwards them to an SNS topic:

```bash
aws events put-rule \
  --name ecr-image-push \
  --event-pattern '{
    "source": ["aws.ecr"],
    "detail-type": ["ECR Image Action"],
    "detail": {"action-type": ["PUSH"]}
  }'

aws events put-targets \
  --rule ecr-image-push \
  --targets "[{\"Id\":\"sns\",\"Arn\":\"arn:aws:sns:<region>:<account-id>:ecr-alerts\"}]"
```

This can invoke an SNS topic, Lambda, or other supported target when a new image is pushed.

## Terraform Snippet

```terraform
resource "aws_cloudwatch_event_rule" "push_alert" {
  name        = "ecr-image-push"
  description = "Trigger on image push"
  event_pattern = <<PATTERN
{
  "source": ["aws.ecr"],
  "detail-type": ["ECR Image Action"],
  "detail": {"action-type": ["PUSH"]}
}
PATTERN
}

resource "aws_cloudwatch_event_target" "push_alert" {
  rule = aws_cloudwatch_event_rule.push_alert.name
  arn  = aws_lambda_function.notify_ecr.arn
}
```
