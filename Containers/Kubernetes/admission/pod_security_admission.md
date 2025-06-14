# 🔐 Pod Security Admission (PSA) in Kubernetes

## 📌 Overview

Pod Security Admission (PSA) is a **built-in admission controller** introduced in Kubernetes v1.22 and enabled by default in v1.25+. It replaces the deprecated PodSecurityPolicy (PSP) mechanism with a simpler, label-based approach for enforcing security standards on Pods at the **namespace level**.

---

## 🚦 Pod Security Standards

PSA enforces one of three built-in profiles on pods:

| Profile      | Intended For                       | Key Restrictions                                          |
| ------------ | ---------------------------------- | --------------------------------------------------------- |
| `privileged` | Admin/debugging pods               | No restrictions                                           |
| `baseline`   | Application pods with basic safety | Blocks hostPath, privileged containers, and more          |
| `restricted` | Hardened environments              | Enforces seccomp, non-root, no privilege escalation, etc. |

Each namespace can enforce these profiles in three **modes**:

- `enforce`: Rejects violating pods
- `audit`: Logs a warning but allows the pod
- `warn`: Sends a warning to the user (kubectl) but allows the pod

You can mix and match these:

```bash
kubectl label ns dev \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

---

## 🧠 Why It Matters

- Replaces PSP, which was overly complex and hard to maintain
- Enables a standardized, declarative way to **enforce runtime security controls**
- Works **without external components** — no need for webhooks or CRDs

---

## ⚙️ How It Works

1. Admin applies labels to a namespace
2. PSA intercepts pod creation/update requests
3. PSA evaluates the pod spec against the namespace's labels
4. Based on `enforce`, `warn`, and `audit`, it takes appropriate action

If a pod violates the policy under `enforce`, it’s rejected:

```bash
Error from server: pod podname is forbidden: violates PodSecurity "restricted": allowPrivilegeEscalation != false
```

---

## 🧪 PSA Practical Walkthrough (warn → enforce)

This hands-on example walks through PSA label application and validation using the `baseline` profile.

### Step 1: Create Namespace with `warn` Mode

```bash
kubectl create namespace dev
kubectl label namespace dev pod-security.kubernetes.io/warn=baseline
```

This allows deploying non-compliant pods while displaying security warnings to the user.

### Step 2: Deploy a Privileged Pod

```yaml
# privileged-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-privileged
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true
```

```bash
kubectl apply -f privileged-pod.yaml -n dev
```

✅ The pod will deploy, but `kubectl` displays a warning message.

### Step 3: Escalate to `enforce` Mode

```bash
kubectl label namespace dev pod-security.kubernetes.io/enforce=baseline --overwrite
```

This makes the baseline policy mandatory.

### Step 4: Reapply the Same Pod

```bash
kubectl apply -f privileged-pod.yaml -n dev
```

❌ Deployment fails. PSA blocks the privileged pod as it violates the `baseline` standard.

---

## 🔧 Best Practices

- Start with `warn` and `audit` to avoid breaking workloads
- Gradually introduce `enforce` in development and then production
- Document namespace policies clearly for developers
- Combine PSA with external tools like Gatekeeper/Kyverno for non-pod resources

---

## 🔄 Limitations

- **Only works on pods** (no coverage for Services, PVCs, etc.)
- Not extensible — can’t define custom policies
- Namespace-only scope: no global fallback enforcement

---

## 🧩 When to Use PSA vs Other Tools

| Use Case                                   | Recommended Tool      |
| ------------------------------------------ | --------------------- |
| Enforce secure pod specs quickly           | ✅ PSA                 |
| Fine-grained custom policies               | 🔁 Gatekeeper/Kyverno |
| Mutate or inject settings (e.g., sidecars) | 🔁 Kyverno            |
| Non-Pod objects (e.g., PVCs, Services)     | 🔁 Gatekeeper/Kyverno |

---

## 🧠 Reflection Questions

- Do your current workloads comply with `restricted`?
- Are developers aware of PSA labels and how they affect pod deployment?
- Would it be useful to log violations before enforcing them?

---

## 📚 Resources

- [Kubernetes Docs - Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [PSA Migration Guide (from PSP)](https://kubernetes.io/docs/concepts/security/previous-psp/)

---

Let’s enforce secure defaults — and only allow more if absolutely necessary. PSA is the low-effort first step to a hardened cluster.

