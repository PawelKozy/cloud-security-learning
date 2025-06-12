"""This Python script uses the `boto3` SDK to:

- Create an IAM user
- Create an S3 bucket
- Define an inline IAM policy allowing access to that bucket
- Create access keys for the user
- Attach the policy to the user

---

## 📦 Requirements

```bash
pip install boto3
"""

import boto3
import json
import random
import string

iam = boto3.client('iam')
s3 = boto3.client('s3')

def generate_bucket_name():
    suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
    return f"example-boto3-bucket-{suffix}"

# 1. Create IAM user
user_name = "example-user"
print(f"Creating IAM user: {user_name}")
iam.create_user(UserName=user_name)

# 2. Create S3 bucket
bucket_name = generate_bucket_name()
print(f"Creating S3 bucket: {bucket_name}")
s3.create_bucket(
    Bucket=bucket_name,
    CreateBucketConfiguration={'LocationConstraint': boto3.session.Session().region_name}
)

# 3. Create inline policy allowing List/Get access
policy_name = "S3ReadAccessPolicy"
bucket_arn = f"arn:aws:s3:::{bucket_name}"
object_arn = f"{bucket_arn}/*"

policy_document = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket", "s3:GetObject"],
            "Resource": [bucket_arn, object_arn]
        }
    ]
}

print("Attaching inline policy to user")
iam.put_user_policy(
    UserName=user_name,
    PolicyName=policy_name,
    PolicyDocument=json.dumps(policy_document)
)

# 4. Create access keys for the user
print("Creating access key")
access_key = iam.create_access_key(UserName=user_name)
print("Access Key ID:", access_key['AccessKey']['AccessKeyId'])
print("Secret Access Key:", access_key['AccessKey']['SecretAccessKey'])
