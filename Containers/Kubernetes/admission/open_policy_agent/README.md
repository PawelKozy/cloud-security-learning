# 🛡️ Open Policy Agent (OPA) and Gatekeeper in Kubernetes

OPA Gatekeeper brings powerful, declarative policy enforcement to Kubernetes through the use of admission control webhooks and custom policies written in the Rego language. It allows platform and security engineers to enforce fine-grained rules across all Kubernetes resources.

---

## 🔍 Why Use OPA Gatekeeper?

- Enforce organization-wide standards (naming, labels, security context)
- Prevent risky configurations before they reach the cluster
- Avoid post-deployment drift and misconfigurations
- Maintain separation of concerns: Devs ship manifests, policies gate them

Gatekeeper extends OPA by integrating directly with Kubernetes through:

- Validating admission webhooks
- Custom Resource Definitions (CRDs)
- Rego-based policies that run on every resource admission

---

## 🧱 Key Concepts

| Concept               | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| ConstraintTemplate    | Defines a new type of policy and embeds Rego code to implement logic        |
| Constraint            | An instance of a ConstraintTemplate that applies rules to specific resources|
| ValidatingWebhook     | Admission webhook used to block non-compliant resources                     |
| Rego                 | Policy language used to express rules and violations                        |

---

## 📁 Folder Structure

This folder documents:

- How OPA Gatekeeper is deployed and functions (`gatekeeper-deployment.md`)
- Practical ConstraintTemplates used for label enforcement, seccomp, etc. (`constrainttemplates/`)
- Rego patterns and best practices (`rego-basics.md`)

OPA is one of the most powerful tools for ensuring Kubernetes compliance and governance at scale.

