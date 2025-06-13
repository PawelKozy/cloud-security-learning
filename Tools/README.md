# 🔧 Tool Overview: Container and Infra Security

This section provides an overview of tools commonly used for container security, infrastructure misconfiguration scanning, runtime detection, and host visibility.

---

## 🔍 What Each Tool Does

| Tool | Purpose | Scans What? | Typical Use Case |
| ---- | ------- | ----------- | ---------------- |
|      |         |             |                  |

| **Clair**   | Container vulnerability scanner                    | Container image layers                   | Deep static analysis of registry-stored images (e.g., Harbor) |
| ----------- | -------------------------------------------------- | ---------------------------------------- | ------------------------------------------------------------- |
| **Trivy**   | All-in-one vulnerability and IaC misconfig scanner | Images, SBOMs, IaC, Git repos            | Fast local scanning for devs, CI pipelines                    |
| **Checkov** | Infrastructure as Code misconfiguration scanner    | Terraform, K8s YAML, ARM, CloudFormation | Security policy enforcement for cloud IaC                     |
| **Grype**   | CVE scanner for container images and SBOMs         | Images, file systems, SBOMs              | Secure builds with Syft integration                           |
| **Falco**   | Runtime security monitoring via eBPF/syscalls      | Running container behavior               | Real-time detection of suspicious container activity          |
| **osquery** | Endpoint observability tool                        | Host processes, network, file integrity  | Threat hunting and incident response on Linux/macOS           |
| **kube-bench** | Kubernetes CIS benchmark checker                 | Cluster nodes & master configs           | Validate compliance and hardening efforts                     |
| **kubeaudit** | Audits Kubernetes security settings              | Pod specs & cluster policies             | Identify misconfigurations quickly                            |
| **Kyverno/OPA** | Policy-as-code engines for Kubernetes           | Admission requests & resources           | Enforce custom security and governance policies               |
| **k9s**    | Terminal UI for cluster management                | Live Kubernetes resources                | Real-time monitoring and troubleshooting                      |
| **kubectl sniff** | Packet capture plugin for kubectl              | Pod network interfaces                   | Debug network traffic within clusters                         |

---

## 🐳 Clair — Container Image Vulnerabilities

**Use case:** Periodic scanning of images stored in registries like Harbor or Quay.

- Works as a service (API-based), not a local CLI
- Focuses on *image layer* analysis using CVE databases

**Pros:**

- Designed for registry integration
- Scalable scanning in CI/CD

**Cons:**

- Requires PostgreSQL and setup
- Less suited for dev workstations

---

## 🚀 Trivy — Swiss Army Knife for App & Infra Scanning

**By Aqua Security**

Scans:

- Container images
- SBOMs
- IaC (Terraform, Kubernetes)
- Git repos and secrets
- OS & language-specific dependencies

```bash
trivy image nginx
trivy config ./terraform
```

**Pros:**

- Fast, works offline
- Great developer experience
- Supports secrets scanning

**Cons:**

- Registry integration not as tight as Clair
- DB pulled on each run (can be cached)

---

## 🧱 Checkov — Infrastructure Misconfiguration Checker

**By Bridgecrew (Prisma Cloud)**

Finds insecure configurations in:

- Terraform
- CloudFormation
- Kubernetes YAML

```bash
checkov -d ./terraform/
```

**Example Issues Detected:**

- Public S3 buckets
- Open security groups (0.0.0.0/0)
- Unencrypted resources

**Pros:**

- Policy-as-code with custom rule support
- GitHub PR enforcement and CI/CD integration

**Cons:**

- Doesn’t scan images or packages — pair with Trivy or Grype

---

## 🐍 Grype — CVE Scanner with SBOM Support

**By Anchore**

- Scans container images and filesystem layers
- Works great with Syft (SBOM generator)

```bash
grype alpine:3.13
```

**Pros:**

- SBOM-native
- Easy to integrate into CI/CD

**Cons:**

- No IaC or secrets scanning

---

## 🔐 Falco — Runtime Security with Syscall Hooks

**By Sysdig**

Detects:

- Unexpected process spawns
- Mount changes
- Network activity anomalies

Uses custom rules (YAML) and eBPF/syscalls.

```bash
falco -r custom_rules.yaml
```

**Pros:**

- Runtime-level protection
- Open-source and eBPF-compatible

**Cons:**

- Needs kernel support
- Higher learning curve for rule tuning

---

## 🕵️ osquery — Host and Container Observability

**Developed by Facebook**

Query your system like a database:

```sql
SELECT * FROM processes WHERE name = 'nginx';
```

Supports live and scheduled queries. Useful for:

- Threat hunting
- Compliance checks
- IR triage

**Pros:**

- Cross-platform
- Well-documented schema

**Cons:**

- Not container-specific
- Requires deployment agent

---

## 🧠 Which Tool to Use When?

| Scenario                                           | Recommended Tool(s) |
| -------------------------------------------------- | ------------------- |
| Scan container images for CVEs                     | ✅ Trivy or Clair    |
| Scan IaC for cloud misconfigurations               | ✅ Checkov           |
| Enforce IaC policy checks in GitHub CI             | ✅ Checkov           |
| Scan for hardcoded secrets in code or configs      | ✅ Trivy             |
| Get real-time detection of container exploits      | ✅ Falco             |
| Query Linux/macOS systems during incident response | ✅ osquery           |
| Create and scan SBOMs for CVEs                     | ✅ Syft + Grype      |
| Check Kubernetes cluster compliance                | ✅ kube-bench        |
| Audit Kubernetes configurations                    | ✅ kubeaudit         |
| Enforce admission policies                         | ✅ Kyverno or OPA    |
| Troubleshoot clusters from the terminal            | ✅ k9s               |
| Capture pod network traffic                        | ✅ kubectl sniff     |

---

## 🔒 Typical Real-World Stack

| What                        | Tool           |
| --------------------------- | -------------- |
| Image scanning              | Trivy or Clair |
| IaC security scanning       | Checkov        |
| Secrets detection           | Trivy          |
| Runtime container detection | Falco          |
| Host observability          | osquery        |

---

