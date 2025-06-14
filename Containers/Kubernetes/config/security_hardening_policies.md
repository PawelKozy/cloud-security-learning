# 🛡️ Kubernetes Security Hardening Policies

## 📌 Overview

This document outlines **practical policies** you can implement in Kubernetes clusters to harden workloads, reduce attack surface, and enforce security best practices. These policies can be enforced using **Pod Security Admission (PSA)** or **external admission controllers** like **Gatekeeper** or **Kyverno**.

---

## 🔐 Baseline Pod Hardening (via PSA or Gatekeeper)

### Enforce Non-Root Containers

```yaml
securityContext:
  runAsNonRoot: true
```

- Prevents processes from running as UID 0
- ✅ Enforced by PSA (restricted)

### Set Explicit User and Group IDs

```yaml
securityContext:
  runAsUser: 1000
  runAsGroup: 3000
  fsGroup: 2000
```

- Defines UID/GID for better traceability and volume access control
- ✅ Enforced by PSA (restricted) for non-root enforcement; full control via Gatekeeper/Kyverno

### Drop All Capabilities by Default

```yaml
securityContext:
  capabilities:
    drop: ["ALL"]
```

- Removes unnecessary Linux capabilities from containers
- ✅ Enforced by PSA (restricted)

### Disallow Privileged Mode

```yaml
securityContext:
  privileged: false
```

- Prevents container from gaining host-level privileges
- ✅ Enforced by PSA (baseline/restricted)

### Disallow Host Path Volumes

```yaml
volumes:
  - name: disallowed
    hostPath:
      path: /etc
      type: Directory
```

- Use policies to block all hostPath volumes
- ✅ Enforced by PSA (baseline/restricted)

---

## 🚫 Disallow Unsafe Patterns

### Deny `latest` Image Tag

- Image tags should be explicit and versioned

```yaml
containers:
- name: app
  image: myapp:latest
```

### Block Host Networking / PID / IPC

```yaml
hostNetwork: false
hostPID: false
hostIPC: false
```

- Avoid unnecessary exposure to host namespaces
- ✅ Enforced by PSA (restricted)

### Block Privilege Escalation

```yaml
securityContext:
  allowPrivilegeEscalation: false
```

- ✅ Enforced by PSA (restricted)

---

## ✅ Required Security Controls

### Enforce seccomp Profiles

```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
```

- Use the container runtime’s default seccomp profile
- ✅ Enforced by PSA (restricted)

### Enforce AppArmor Profiles (if supported)

```yaml
annotations:
  container.apparmor.security.beta.kubernetes.io/my-container: localhost/my-profile
```

- This setting is only applicable if your Linux host supports AppArmor (e.g., Ubuntu).
- Pod Security Admission does not evaluate AppArmor settings.
- If enforcing AppArmor is critical, use Gatekeeper or Kyverno to validate the presence of expected annotations.

### ReadOnlyRootFilesystem

```yaml
securityContext:
  readOnlyRootFilesystem: true
```

- Makes filesystem immutable, reducing malware risk
- ✅ Enforced by PSA (restricted)

### Set Image Pull Policy

```yaml
imagePullPolicy: Always
```

- Ensures the container image is pulled on every deployment rather than using cached layers.
- Not evaluated by PSA.
- You can use Gatekeeper or Kyverno to enforce this rule across deployments.

### Define Resource Limits and Requests

```yaml
resources:
  limits:
    memory: "512Mi"
    cpu: "500m"
  requests:
    memory: "256Mi"
    cpu: "250m"
```

- Prevents resource abuse and improves scheduling accuracy.
- PSA does not validate these values.
- Gatekeeper or Kyverno can enforce that containers declare both `requests` and `limits`.

### Mandatory Labels for Governance

Use Gatekeeper or Kyverno to ensure that all workloads include critical labels, such as:

- `team`
- `owner`
- `env`

These labels improve traceability and governance but are not enforced by PSA. Gatekeeper and Kyverno can be configured to reject unlabeled workloads.

---

## 🧩 Enforcement with Tools

| Tool       | Use Case                      | Notes                             |
| ---------- | ----------------------------- | --------------------------------- |
| PSA        | Enforce basic pod-level rules | Fast, built-in, not extensible    |
| Gatekeeper | Rego-based policy enforcement | Great for custom org requirements |
| Kyverno    | YAML-native policy engine     | Easier for platform/dev teams     |

---

## 🚀 Suggested Strategy

1. **Start with PSA** in `audit` or `warn` mode
2. Layer in **Gatekeeper/Kyverno** for custom rules
3. Define org-wide **security baselines** as code
4. Monitor violations before enforcing

---

## 📚 Example Policy Sets

- Baseline: PSA `baseline`, no `hostPath`, no `privileged`, no `latest`
- Restricted: PSA `restricted`, Gatekeeper enforced `seccomp`, `readonlyrootfs`, required labels, explicit UID/GID, resource limits

---

## 🧠 Reflection Questions

- What are the most common security gaps in your cluster workloads?
- Are there legacy apps that would break under stricter policies?
- Can your CI/CD pipelines validate policy compliance pre-deploy?

---

Security hardening is not one policy — it’s a layered, evolving defense. Let policies be your first line of runtime security.

