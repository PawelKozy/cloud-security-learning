# 📙 Kubernetes Admission Controllers

Admission controllers are a critical layer of control in the Kubernetes API request lifecycle. They intercept requests **after authentication and authorization**, and either **validate, modify, or reject** them before they're persisted in etcd. Think of them like a CSP or IAM policy in the cloud — they determine what is allowed even after access is granted.

---

## 🚪 What Are Admission Controllers?

Admission controllers are plugins configured on the **kube-apiserver**. They control how the cluster behaves by evaluating or mutating resource creation and modification requests.

They can:

- Enforce policies (e.g., "must not use privileged containers")
- Auto-inject configurations (e.g., sidecars)
- Validate security posture (e.g., deny use of external IPs)

To enable them:

```bash
--enable-admission-plugins=NamespaceLifecycle,PodSecurity,...
```

---

## 🔐 Security & Policy Enforcement Plugins

### `PodSecurity`

- Enforces Pod Security Standards (`restricted`, `baseline`, `privileged`) via namespace labels
- Modes: `enforce`, `warn`, `audit`

### `NamespaceLifecycle`

- Prevents resource creation in terminating or initializing namespaces

### `LimitRanger`

- Sets default CPU/memory and enforces namespace limits

### `ResourceQuota`

- Enforces quotas on resource usage (CPU, memory, PVCs, object count)

### `SecurityContextDeny` *(deprecated)*

- Block pods using privileged `securityContext` fields
- Replaced by `PodSecurity` and policy engines like OPA

---

## 🔁 Mutation and Automation

### `MutatingAdmissionWebhook`

- Automatically modifies objects before they’re persisted
- Common uses:
  - Sidecar injection (e.g., Istio, Linkerd)
  - Add default labels or security settings

Example use cases:

- Injecting OpenTelemetry collector
- Adding init containers

---

## ✅ Validation and Governance

### `ValidatingAdmissionWebhook`

- Rejects non-compliant resources based on custom logic
- Often used with:
  - **OPA Gatekeeper**: Rego policies
  - **Kyverno**: YAML-native policy engine

### `DenyServiceExternalIPs`

- Blocks use of `spec.externalIPs` in services to avoid hijacking risks

### `AlwaysPullImages`

- Forces image pulls on every pod start, even if cached
- Useful for preventing stale or tampered images

---

## 📦 Storage & Networking Control

### `PersistentVolumeClaimResize`

- Enforces or restricts resizing of volumes

### `ExternalIPRanger` *(custom)*

- Custom controller to restrict which external IPs can be assigned

---

## 💡 Custom Admission Workflows

### 🔍 Validating Webhook Example

Using OPA to block untrusted image registries:

```rego
package kubernetes.validating.images

deny[msg] {
  input.request.kind.kind == "Pod"
  some container in input.request.object.spec.containers
  not startswith(container.image, "hooli.com/")
  msg := sprintf("Image '%v' comes from untrusted registry", [container.image])
}
```

### 🔧 Mutating Webhook Example

Automatically inject an annotation:

```json
{
  "op": "add",
  "path": "/metadata/annotations/example.com~1team",
  "value": "platform"
}
```

---

## 📈 Webhook Lifecycle and Configuration

### ⏱️ Ordering of Webhooks

- Kubernetes always executes **mutating webhooks before validating webhooks**.
- Within each category, the order is not guaranteed.
- If a mutating webhook changes a resource, all validation webhooks will see the modified version.

### ⚖️ Admission Controller Config File

You can pass a config file to the API server using:

```bash
--admission-control-config-file=/etc/kubernetes/admission-config.yaml
```

This allows fine-tuned configuration for plugins like `ImagePolicyWebhook`, and advanced control over webhook timeouts, retries, and failure behavior.

### 📃 Audit Logging and Admission Control

- Kubernetes audit logs can capture webhook admission decisions if audit policy is configured to log `requestResponse` or `metadata` for `admit` stages.
- This is essential for:
  - Troubleshooting denied requests
  - Understanding mutation side effects
  - Validating compliance over time

---

## 📌 Summary Table

| Plugin                 | Category   | Example Use                   |
| ---------------------- | ---------- | ----------------------------- |
| PodSecurity            | Security   | Enforce restricted containers |
| LimitRanger            | Quotas     | Set default CPU/memory        |
| ValidatingWebhook      | Policy     | Block `:latest` images        |
| MutatingWebhook        | Automation | Inject sidecars               |
| DenyServiceExternalIPs | Security   | Block hijacking risk          |
| AlwaysPullImages       | Security   | Ensure fresh image use        |

---

## 🧠 Reflections

- Do your webhooks apply to all resource types, or just specific kinds?
- How do you test webhook changes safely?
- Should mutation precede validation in your pipeline?
- Do you audit webhook decisions to understand impact and drift?

Admission controllers help enforce consistency and security across your cluster, especially in multi-team environments. Used properly, they can significantly reduce misconfigurations and policy drift.

