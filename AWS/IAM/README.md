# AWS IAM — Identity and Access Management

## 📌 Introduction

IAM (Identity and Access Management) is AWS’s service for managing *who* can access *what* in your cloud environment. It enables secure access control through users, roles, policies, and trust relationships.

This section covers IAM Roles, authentication mechanics, policy structure, and Incident Response (IR) implications.

---

## 🧠 Core Concepts

### 🔹 Amazon Resource Name (ARN)

ARNs uniquely identify AWS resources globally. Format:

```text
arn:partition:service:region:account-id:resource
```

Example:

```text
arn:aws:iam::123456789012:role/MyExampleRole
```

### 👤 IAM Users and Access

IAM users are long-lived identities used by humans. They can authenticate via:

- **Access key / secret key pairs** (programmatic access)
- **Username + password** (for AWS Console)
- **MFA** (Multi-Factor Authentication)

Best practices:

- Avoid root user for anything except break-glass scenarios
- Enforce MFA on all users
- Minimize use of long-lived access keys

🧪 **Example:** Access key prefix `AKIA` denotes a standard IAM access key.

### 🚫 Avoid this:

- Hardcoding access keys in source code
- Over-permissive policies (e.g., `"Action": "*"`)
- Skipping MFA for sensitive accounts

---

## 🛠️ IAM Roles – Temporary and Flexible Access

An IAM Role is a temporary identity that can be assumed by users, services, or other AWS principals. It has two distinct types of policies:

- **Trust Policy**: Defines *who* can assume the role. This is part of the role’s configuration.
- **Permissions Policy**: Defines *what* actions are allowed once the role is assumed.

These are both attached to the same role, but they serve different purposes. The trust policy is required at creation; the permissions policy is usually added afterward.

### 🔁 Role Assumption Flow Recap:

1. EC2 or another AWS service is configured to use a role.
2. The trust policy allows that service (e.g., `ec2.amazonaws.com`) to assume the role.
3. When the instance/application makes AWS API calls, the AWS SDK/CLI fetches temporary credentials from the **Instance Metadata Service (IMDS)**.
4. STS returns `AccessKeyId`, `SecretAccessKey`, and `SessionToken`, which are used in API calls.

No code inside the EC2 instance needs to explicitly handle `sts:AssumeRole` — it's handled transparently if using the SDK or CLI.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### 🤔 Can users see what roles they can assume?

Not directly. You need to:

- Know the ARN of the role
- Have permission to call `sts:AssumeRole`
- Optionally use `ListRoles` + `SimulatePrincipalPolicy` for discovery

### 🔄 Can users assume multiple roles?

Yes, but only one at a time per session. Each switch requires a new `sts:AssumeRole` call.

---

## 🔁 Temporary Credentials Lifecycle

### ⏳ How Temporary Credentials Work

- Returned by `sts:AssumeRole`, `GetSessionToken`, or `AssumeRoleWithSAML`
- Include `AccessKeyId`, `SecretAccessKey`, and `SessionToken`
- Stored in environment variables for CLI and SDKs:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
```

- They automatically expire (default: 1 hour; max: 12 hours)

### 🔁 Rotating or Expiring Credentials

- Rotate by re-calling `AssumeRole` to get fresh temporary credentials
- Monitor expiration and refresh sessions in automation scripts
- Avoid hardcoded values in config files — use credential helpers or STS-integrated SDKs

### 🔗 Role Chaining & Session Duration

- A role that assumes another role (role chaining) shortens max session to the lower value
- Default max session is 1 hour unless extended to 12h with `maxSessionDuration` on the role

Implications:
- Role chaining can reduce visibility and complicate IR attribution
- Expired credentials mitigate long-term risk after compromise

---

## 🧰 Delegation vs. Impersonation

### 🔁 Delegation (AssumeRole)

- Performed via CLI or SDK
- Requires `sts:AssumeRole` permission and a trust policy
- Used in automation, federation, and temporary privilege escalation

```bash
aws sts assume-role --role-arn arn:aws:iam::123456789012:role/AdminRole --role-session-name debugSession
```

### 👥 Impersonation (Switch Role in Console)

- UI-driven: users click "Switch Role" in AWS Console
- Relies on same `sts:AssumeRole`, but session is started through the web UI
- Used for cross-account access or role-based administration

Use AssumeRole when:
- Scripting or automating cross-account actions
- Integrating federated identity providers

Use Switch Role when:
- Human operators need to jump between roles interactively

---

## 🔐 Policy Types and Attributes

### Policy Types

- **Identity-based** (attached to Users, Groups, Roles)
- **Resource-based** (e.g., S3 bucket policies)
- **Inline policies** (embedded directly inside an identity)
- **Service Control Policies (SCPs)** — applied at the Org level to define boundaries

### Key Attributes

- **Statements** — permission blocks inside the policy
- **Effect** — `Allow` or `Deny` (Deny is implicit by default)
- **Actions** — what actions are allowed or denied
- **Resources** — what resources are affected
- **Conditions** — additional logic to limit when the rule applies

🧪 Example conditional logic:

```json
"Condition": {
  "IpAddress": {"aws:SourceIp": "192.0.2.0/24"},
  "Bool": {"aws:MultiFactorAuthPresent": "true"}
}
```
## 🧱 Resource-Based Policies

Resource-based policies are policies attached **directly to a resource** (like an S3 bucket, Lambda function, or SQS queue). They define *who can access* the resource and *what they can do*, independently of IAM identity policies.

### 🧪 Example S3 Bucket Policy (Resource-Based)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::111122223333:user/ExternalUser"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

### 🔍 Key Differences from IAM Identity Policies:

- Resource policies include a `Principal` (identity policies do not).
- They allow cross-account access **without needing to assume a role**.
- AWS evaluates both identity and resource policies when deciding access.

Reflection: *What’s the implication of allowing wildcards in Action or Resource?*

---

## 🚨 IAM in Incident Response

From an IR perspective:

- **Check CloudTrail** for `sts:AssumeRole` actions to trace role usage
- **Correlate temporary credentials** to session activity
- **Analyze policy changes**, especially privilege escalation vectors (e.g., `iam:PassRole`, `iam:CreateAccessKey`)
- **Investigate when a role was last assumed**, and by whom (via CloudTrail and Access Analyzer)

Reflection: *If an attacker gets a foothold via an IAM user, how can your IAM role design limit impact?*

---

## 🧪 Tools

- **IAM Access Analyzer** — detect unintended access across accounts
- **Credential Reports** — show age of keys, use of MFA
- **Policy Simulator** — test whether a principal has access to specific actions

---

## ✅ Summary Table

| Concept      | Description                                         |
| ------------ | --------------------------------------------------- |
| IAM User     | Long-term identity, supports access keys + console  |
| IAM Role     | Temporary identity assumed by users, apps, services |
| Trust Policy | Defines who can assume the role                     |
| AssumeRole   | API call that returns temporary credentials         |
| STS          | Security Token Service powering temporary access    |
| SCP          | Org-level boundary for what accounts can do         |

---

