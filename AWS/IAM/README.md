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

IAM Roles are identities you assume temporarily. They’re not tied to specific users or passwords.

### 🧩 Authentication Flow

1. **A trusted entity** (IAM user, EC2, Lambda) calls `sts:AssumeRole`
2. **Trust policy** is checked — defines who can assume this role
3. **STS** returns temporary credentials (AccessKeyId, SecretAccessKey, SessionToken)
4. The entity uses these credentials to perform actions within the role’s permissions

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

## 🧭 Reflections

- Have you audited your IAM roles and policies for least privilege?
- Are you using Access Analyzer to detect unintended access?
- Do you log and alert on `sts:AssumeRole`, `CreateAccessKey`, and `AttachUserPolicy`?
- Can your incident response team trace session activity back to a human or system?

---

Let me know when you’re ready to:

- Add Terraform / Azure CLI / Boto3 IAM setup examples
- Diagram the `AssumeRole` workflow
- Expand with common IAM misconfigurations (e.g., privilege escalation via PassRole)

