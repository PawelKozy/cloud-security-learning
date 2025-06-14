# ServiceAccount to Cloud API Access in Kubernetes

In modern Kubernetes deployments on cloud providers like AWS, GCP, and Azure, Kubernetes **ServiceAccounts (SAs)** can be mapped to **cloud-native identities**. This allows pods to access external cloud APIs (e.g., S3, KMS, GCS) without embedding static credentials. However, this integration can be abused if misconfigured.

---

## ☁️ Cloud-Specific Integrations

### 🔹 AWS: IAM Roles for ServiceAccounts (IRSA)

- Uses **OIDC federation** to allow Kubernetes SAs to assume AWS IAM roles.
- SA must be annotated with the IAM role ARN:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-access-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/S3ReadOnlyRole
```

- The pod receives temporary AWS credentials from the EC2 metadata service after OIDC token exchange.
- **Used for**: S3, Secrets Manager, DynamoDB, KMS access.

### 🔹 GCP: Workload Identity

- Maps a Kubernetes SA to a **Google Cloud IAM Service Account**.
- Enables federated identity using GCP STS and IAM policy bindings.

```bash
gcloud iam service-accounts add-iam-policy-binding \
  gsa-name@project.iam.gserviceaccount.com \
  --member="serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]" \
  --role="roles/storage.objectViewer"
```

- Pod receivess a projected token that GCP accepts to mint access tokens.
- **Used for**: GCS, BigQuery, Secret Manager, PubSub access.

### 🔹 Azure: Pod Managed Identity (Preview / evolving)

- Uses the Azure Identity SDK and Microsoft Entra Workload ID.
- Still under active development and less mature than IRSA/Workload Identity.

---

## 🔓 Security Risks

### If a pod is compromised:

- Attacker can **read the mounted SA token**.
- Use it to authenticate to **cloud APIs** via the projected credentials.
- Access cloud data or escalate if IAM roles are over-permissive.

### Typical Abuses:

- Read secrets from Secrets Manager / Secret Manager
- Access S3/GCS buckets to exfiltrate data
- Call KMS APIs to decrypt data
- Abuse metadata APIs for further recon

---

## 🔍 Detection Ideas

- **Audit cloud API calls** originating from the node or pod identity.
- Detect calls to `sts:AssumeRoleWithWebIdentity`, `storage.objects.get`, etc.
- Monitor access patterns tied to federated identities from the cluster.
- On GCP, use Cloud Audit Logs; on AWS, use CloudTrail.

---

## ✅ Defensive Best Practices

- Use **fine-grained IAM roles** mapped to purpose-specific SAs.
- Restrict token audience and duration.
- Use \`\` for pods that don’t need API access.
- Monitor and alert on cloud API access anomalies from federated pods.

---

## 📚 Further Reading

- [IRSA with EKS](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [GKE Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [Azure Workload Identity](https://azure.github.io/azure-workload-identity/docs/)

