# ⚙️ Deploying OPA Gatekeeper in Kubernetes

This guide explains what happens when you deploy OPA Gatekeeper via its `deploy.yaml`, how it integrates into the Kubernetes API server, and how it enables policy enforcement through admission control.

---

## 🚀 What the `deploy.yaml` Does

The `deploy.yaml` file provisions the Gatekeeper infrastructure:

- Creates a dedicated `gatekeeper-system` namespace
- Installs a set of CRDs for Gatekeeper types (`ConstraintTemplate`, `Assign`, etc.)
- Deploys controller pods and service accounts
- Registers a `ValidatingWebhookConfiguration` to intercept object creation

Gatekeeper runs as a Kubernetes controller and listens to admission events via webhooks.

---

## 🔗 Webhook Integration

- Gatekeeper configures a `ValidatingWebhookConfiguration`
- The API server sends resource admission requests to Gatekeeper pods (via a ClusterIP Service)
- TLS is enforced; certificates are provisioned and rotated automatically
- Port 8443 is used **inside the pod**, not exposed externally

This makes Gatekeeper *cluster-wide* and policy-aware at the control plane level.

---

## 🧠 How Enforcement Works

Once deployed:

1. You create a `ConstraintTemplate` that includes Rego logic
2. You apply one or more `Constraint` objects to activate that logic against specific resources
3. When a resource is created/modified, Kubernetes calls the Gatekeeper webhook
4. Gatekeeper evaluates the resource against all active constraints
5. If any violations are found → the resource is rejected with a detailed message

All of this happens **before the object is persisted to etcd**.

---

## 💡 Deployment Notes

- Gatekeeper is a *validating admission controller*, but it can also mutate objects via Assign-style templates
- It operates on **all API server calls**, not just `kubectl`
- All configurations (`ConstraintTemplates`, `Constraints`, etc.) are standard Kubernetes objects stored in etcd

---

This foundational setup enables scalable, centralized policy enforcement across any Kubernetes environment.

