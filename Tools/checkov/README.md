# 🛠️ Checkov

## 🔍 1. What problem does this tool solve?

Checkov helps identify **security and compliance misconfigurations** in Infrastructure as Code (IaC) before deployment. It supports Terraform, CloudFormation, Kubernetes manifests, ARM templates, and more. This early detection helps prevent cloud misconfigurations that could lead to breaches or compliance violations.

## 💡 2. Why would I use this tool over alternatives?

- Native support for a wide range of IaC formats.
- Rich library of built-in policies (e.g., CIS, SOC2, NIST).
- Easy integration with CI/CD pipelines.
- Written in Python and highly customizable.
- Supports custom policies via YAML or Python.

Compared to tools like TFLint or Terraform built-in validation, Checkov offers **security-focused, multi-cloud-aware scanning**.

## ✅ 3. When is it a good fit?

- You use Terraform, CloudFormation, or Kubernetes manifests in your deployment pipeline.
- You want to shift security left into CI/CD.
- You need to enforce compliance baselines (CIS AWS Foundations, PCI-DSS, etc.).
- You want a fast feedback loop during pull requests.

## ⚠️ 4. When is it not a good fit?

- You’re working only with runtime configurations (e.g., container images) — use Trivy or Clair instead.
- You need commercial-grade policy enforcement with workflow integration — consider Bridgecrew SaaS.
- Your IaC is extremely dynamic or generated at runtime — static scanning may miss logic-dependent conditions.

## 🔐 5. How secure is it? Are there any concerns?

Checkov performs **static analysis only** — it doesn’t handle secrets directly or execute code. It's safe to run locally or in CI.

However:

- False positives/negatives may occur in complex modules or conditionals.
- If uploading scan results to SaaS (Bridgecrew), review data handling policies.

## 📦 6. How does it integrate with Containers/Kubernetes/Cloud?

- **Kubernetes**: Scans YAML manifests and Helm charts for misconfigurations (e.g., privileged containers, lack of resource limits).
- **Containers**: Not a container image scanner. Pair with Trivy or Grype for vulnerability scanning.
- **Cloud**: Supports AWS, Azure, GCP IaC definitions.

You can use it in GitHub Actions, GitLab CI, CircleCI, Jenkins, and more.

## ⚙️ 7. How does it actually work? (High-level flow)

1. Parses the IaC code (Terraform, Kubernetes YAML, etc.)
2. Loads built-in and custom policies.
3. Evaluates each block/resource against the policies.
4. Outputs a detailed report (CLI, JSON, SARIF, etc.)

## 🚀 8. Quick Start / Common Commands

Install:

```bash
pip install checkov
```

Scan a Terraform directory:

```bash
checkov -d ./terraform
```

Scan a Kubernetes manifest:

```bash
checkov -f deployment.yaml
```

Use a specific framework (e.g., CIS):

```bash
checkov -d . --framework cis_aws
```

## 🧠 9. What to learn next?

- Try a hands-on lab: “Misconfigured Terraform Challenge” from KodeKloud or similar.
- Create your own custom policy (YAML or Python).
- Combine Checkov with Trivy in CI to cover IaC and image scanning.
- Explore using it in pre-commit hooks to enforce IaC hygiene.

---

Feel free to expand this with detection use cases or IaC examples from your own environments.

