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

### Drop All Capabilities by Default
```yaml
securityContext:
  capabilities:
    drop: ["ALL"]
```
- Removes unnecessary Linux capabilities from containers

### Disallow Privileged Mode
```yaml
securityContext:
  privileged: false
```
- Prevents container from gaining host-level privileges

### Disallow Host Path Volumes
```yaml
volumes:
  - name: disallowed
    hostPath:
      path: /etc
      type: Directory
```
- Use policies to block all hostPath volumes

---

## 🚫 Disallow Unsafe Patterns

### Deny `latest` Image Tag
- Image tags should be explicit and versioned
- Gatekeeper/Kyverno can reject deployments like:
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

### Block Privilege Escalation
```yaml
securityContext:
  allowPrivilegeEscalation: false
```

---

## ✅ Required Security Controls

### Enforce seccomp Profiles
```yaml
securityContext:
  seccompProfile:
    type: RuntimeDefault
```
- Use the container runtime’s default seccomp profile

### ReadOnlyRootFilesystem
```yaml
securityContext:
  readOnlyRootFilesystem: true
```
- Makes filesystem immutable, reducing malware risk

### Mandatory Labels for Governance
Use Gatekeeper/Kyverno to require labels:
- `team`
- `owner`
- `env`

---

## 🧩 Enforcement with Tools

| Tool       | Use Case                          | Notes                              |
|------------|-----------------------------------|-------------------------------------|
| PSA        | Enforce basic pod-level rules     | Fast, built-in, not extensible      |
| Gatekeeper | Rego-based policy enforcement     | Great for custom org requirements   |
| Kyverno    | YAML-native policy engine         | Easier for platform/dev teams       |

---

## 🚀 Suggested Strategy
1. **Start with PSA** in `audit` or `warn` mode
2. Layer in **Gatekeeper/Kyverno** for custom rules
3. Define org-wide **security baselines** as code
4. Monitor violations before enforcing

---

## 📚 Example Policy Sets
- Baseline: PSA `baseline`, no `hostPath`, no `privileged`, no `latest`
- Restricted: PSA `restricted`, Gatekeeper enforced `seccomp`, `readonlyrootfs`, required labels

---

## 🧠 Reflection Questions
- What are the most common security gaps in your cluster workloads?
- Are there legacy apps that would break under stricter policies?
- Can your CI/CD pipelines validate policy compliance pre-deploy?

---

Security hardening is not one policy — it’s a layered, evolving defense.
Let policies be your first line of runtime security.

