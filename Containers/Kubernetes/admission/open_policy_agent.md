# 🧠 Kubernetes Policy Management with Open Policy Agent (OPA)

Open Policy Agent (OPA) is a general-purpose policy engine that allows you to write policies as code using the **Rego** language. In Kubernetes, OPA is commonly used with **Gatekeeper**, which integrates as a Validating Admission Webhook to enforce policies at admission time.

---

## 🔍 Why Use OPA?

OPA allows you to:
- Define custom rules for Kubernetes resource validation
- Enforce consistent policies across teams and namespaces
- Decouple policy from application code or manifests
- Audit policy decisions

OPA evaluates requests based on a **JSON representation** of the Kubernetes object being created or updated.

---

## 🧱 Core Concepts

### Rego Language
Rego is a declarative query language used to define policy logic.

A basic deny rule example:
```rego
package kubernetes.validating.images

deny[msg] {
  input.request.kind.kind == "Pod"
  some container in input.request.object.spec.containers
  not startswith(container.image, "hooli.com/")
  msg := sprintf("Image '%v' comes from untrusted registry", [container.image])
}
```

### Data and Input
OPA receives a JSON input object (like a Kubernetes AdmissionReview request) and uses it to evaluate rules.

- `input`: request metadata, object spec, etc.
- `data`: external context or policy config if needed

---

## ⚖️ OPA Gatekeeper vs Standalone OPA

| Feature | OPA Gatekeeper | Standalone OPA |
|--------|----------------|----------------|
| Deployment | Runs inside Kubernetes as a controller + CRDs | Runs as a separate binary or container |
| Purpose | Kubernetes-native admission control | General-purpose policy engine (can be used anywhere) |
| Policy Language | Rego | Rego |
| Integration | Deep integration with Kubernetes (audit, webhook, CRDs) | Needs custom webhook integration if used in K8s |
| Resource Matching | Declarative via `Constraint` and `ConstraintTemplate` | Manual logic in Rego policies |
| Auditing | Built-in audit controller scans cluster resources | Requires external scripting/logging setup |

Use Gatekeeper if you want:
- Admission control via Kubernetes-native workflows
- Policy deployment and binding using YAML
- CRDs for manageability and visibility

Use standalone OPA if you want:
- To enforce policies outside Kubernetes (e.g., API gateway, CI/CD pipeline)
- Complete control over webhook logic or evaluation flow

---

## 🚦 OPA Gatekeeper Integration

Gatekeeper deploys OPA into your Kubernetes cluster and provides:
- CRDs: `ConstraintTemplate`, `Constraint`
- Admission webhook for real-time enforcement
- Audit controller to scan existing resources

### 🧩 Example: Deny `latest` image tag

#### 1. Create a `ConstraintTemplate`
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8sdisallowlatest
spec:
  crd:
    spec:
      names:
        kind: K8sDisallowLatest
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8sdisallowlatest

        violation[{
          "msg": msg
        }] {
          container := input.review.object.spec.containers[_]
          endswith(container.image, ":latest")
          msg := sprintf("Image uses 'latest' tag: %v", [container.image])
        }
```

#### 2. Create a `Constraint`
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sDisallowLatest
metadata:
  name: disallow-latest-tag
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

---

## 🧪 Testing & Auditing

Gatekeeper supports an audit controller that scans existing cluster resources for policy violations.

```bash
gk audit
```

Violations are reported as `ConstraintViolations` in CRDs and can be integrated with observability pipelines.

---

## 🧠 Reflections

- Do you need fine-grained policy enforcement across teams?
- Are you enforcing rules on existing resources or just new ones?
- How do you ensure your Rego policies are tested and versioned?

---

OPA gives you a declarative, programmable way to enforce organization-wide Kubernetes policies — from allowed registries to restricted capabilities. It’s especially powerful when paired with Gatekeeper for real-time admission control and auditing.

