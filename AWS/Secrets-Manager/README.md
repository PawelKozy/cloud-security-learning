# Secrets Management and Encryption in AWS

## 🧩 Introduction

Securely storing and managing secrets—such as API keys, credentials, and tokens—is essential for maintaining security posture in AWS. AWS provides several services for this purpose:

- **AWS Secrets Manager**
- **AWS Systems Manager Parameter Store**
- **AWS Key Management Service (KMS)**

This document outlines how each service works, when to use them, cost considerations, and encryption best practices.

---

## 🔐 AWS Secrets Manager

**Purpose:** Store and manage secrets securely, with automatic rotation and fine-grained access control.

**Key Features:**

- Integrated secret rotation using AWS Lambda.
- Versioning and automatic rotation policies.
- Audit logging via CloudTrail.
- Native support for RDS, Redshift, DocumentDB credential rotation.

**Pricing:**

- Charged per secret stored per month.
- Additional charges for API calls (e.g., GetSecretValue).

**Example Use Case:**

- Storing a database password and configuring automatic rotation every 30 days.

```json
{
  "username": "dbadmin",
  "password": "secure-password-123"
}
```

> 🔍 **Reflection:** What’s the risk of storing secrets in plaintext within environment variables or code?

---

## 🛠️ AWS Systems Manager Parameter Store

**Purpose:** Store configuration and secrets as parameters.

**Key Concepts:**

- Supports standard (free) and advanced (paid) parameters.
- Use `SecureString` to encrypt values with AWS KMS.

```bash
aws ssm put-parameter \
  --name "/prod/db/password" \
  --value "secure-password-123" \
  --type "SecureString" \
  --key-id "alias/aws/ssm"
```

**Vault Control:**

- Fine-grained IAM policies can control who can read or write individual parameters.

**Free Tier:**

- Standard parameters (non-rotated secrets, fewer API calls) are free.

**When to Use:**

- Lightweight configuration management and secrets where automatic rotation is not needed.

> 🧠 **Reflection:** What are the limitations of using Parameter Store instead of Secrets Manager?

---

## 🔐 AWS Key Management Service (KMS)

**Purpose:** Central service for creating and managing cryptographic keys.

**Used By:** Nearly all AWS services for encryption at rest (e.g., S3, EBS, RDS).

**Key Types:**

- AWS-managed CMKs (auto-created per service).
- Customer-managed CMKs (user-created, configurable).
- Customer-provided keys (via Bring Your Own Key, BYOK).

**Common Actions:**

- Encrypt and decrypt data
- Generate data keys for envelope encryption

```bash
aws kms encrypt \
  --key-id alias/my-key \
  --plaintext "TopSecret"
```

**Auditability:**

- Integrated with CloudTrail for tracking key usage.

---

## 🔄 Server-Side vs Client-Side Encryption

| Feature          | Server-Side Encryption        | Client-Side Encryption                     |
| ---------------- | ----------------------------- | ------------------------------------------ |
| Who manages keys | AWS manages (via KMS)         | Customer encrypts before sending           |
| Key rotation     | Managed by AWS                | Must be handled by the customer            |
| Visibility       | Encrypted at rest in AWS      | AWS never sees unencrypted data            |
| Common Use Cases | S3, EBS, RDS, Secrets Manager | Sensitive uploads to S3, custom data flows |

> 💡 **Reflection:** When would client-side encryption be required despite AWS offering server-side options?

---

## 📦 Summary

| Service         | Rotation        | KMS Integration | Cost                    | Typical Use Case                                      |
| --------------- | --------------- | --------------- | ----------------------- | ----------------------------------------------------- |
| Secrets Manager | Yes             | Native          | Charged per secret      | Auto-rotated credentials, high sensitivity secrets    |
| Parameter Store | No (by default) | Optional        | Free (standard)         | App configs, simple secrets, basic credential storage |
| KMS             | N/A             | Core service    | Per API call, key usage | Encrypt everything: storage, DB, apps, logs           |

