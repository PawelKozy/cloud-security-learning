# Monitoring ECR with CloudTrail and Athena

These notes outline how to capture Amazon ECR activity and analyze the events with Amazon Athena.

## Create a repository and push an image
1. Create a repository:
   ```bash
   aws ecr create-repository --repository-name demo --image-scanning-configuration scanOnPush=true
   ```
2. Authenticate and push a Docker image:
   ```bash
   aws ecr get-login-password --region <region> | \
     docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   docker tag demo:latest <account-id>.dkr.ecr.<region>.amazonaws.com/demo:latest
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/demo:latest
   ```

## Configure CloudTrail with S3 and KMS encryption
1. Create an S3 bucket to store logs and a KMS key:
   ```bash
   aws s3api create-bucket --bucket ecr-trail-logs --region <region> --create-bucket-configuration LocationConstraint=<region>
   aws kms create-key --description "CloudTrail key"
   ```
2. Create the trail and start logging:
   ```bash
   aws cloudtrail create-trail --name ecr-trail \
     --s3-bucket-name ecr-trail-logs \
     --kms-key-id <kms-key-arn>
   aws cloudtrail start-logging --name ecr-trail
   ```

## Exclude KMS events with an event selector
Configure an event selector so KMS activity doesn't clutter the trail:
```bash
aws cloudtrail put-event-selectors --trail-name ecr-trail --event-selectors '
[
  {
    "ReadWriteType": "All",
    "IncludeManagementEvents": true,
    "DataResources": [],
    "ExcludeManagementEventSources": ["kms.amazonaws.com"]
  }
]'
```

## Query ECR events using Amazon Athena
1. Set up a table based on the CloudTrail JSON schema:
   ```sql
   CREATE EXTERNAL TABLE ecr_cloudtrail_logs (
     eventVersion STRING,
     userIdentity STRUCT<
       type: STRING,
       principalId: STRING,
       arn: STRING,
       accountId: STRING,
       accessKeyId: STRING,
       userName: STRING
     >,
     eventTime STRING,
     eventSource STRING,
     eventName STRING,
     awsRegion STRING,
     sourceIPAddress STRING,
     userAgent STRING,
     requestParameters STRING,
     responseElements STRING,
     additionalEventData STRING,
     requestId STRING,
     eventId STRING,
     readOnly STRING,
     resources ARRAY<STRUCT<arn:STRING, accountId:STRING, type:STRING>>,
     eventType STRING,
     managementEvent STRING,
     recipientAccountId STRING,
     serviceEventDetails STRING,
     sharedEventID STRING,
     vpcEndpointId STRING
   )
   PARTITIONED BY (region STRING, year STRING, month STRING, day STRING)
   ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
   LOCATION 's3://ecr-trail-logs/AWSLogs/<account-id>/CloudTrail/'
   TBLPROPERTIES ('classification'='json');
   ```
2. Retrieve recent ECR operations:
   ```sql
   SELECT eventTime, eventName, userIdentity.userName
   FROM ecr_cloudtrail_logs
   WHERE eventSource = 'ecr.amazonaws.com'
   ORDER BY eventTime DESC
   LIMIT 50;
   ```

