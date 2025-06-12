# 🛠️ Trivy

## 🔍 1. What problem does this tool solve?

Trivy is an **all-in-one security scanner** that detects vulnerabilities, misconfigurations, secrets, and license issues in container images, Kubernetes configs, SBOMs, IaC, and source code repositories. It enables developers and security engineers to shift security left and catch issues early in CI/CD pipelines.

## 💡 2. Why would I use this tool over alternatives?

- Lightning-fast scans, even locally.
- Wide coverage: images, Dockerfiles, IaC, Git repos, SBOMs.
- Simple CLI with zero-config by default.
- Native support for scanning GitHub repos and Docker Hub.
- Actively maintained by Aqua Security, open source, and cloud-native friendly.

Compared to Clair or Grype, Trivy is more versatile and easier to use out of the box.

## ✅ 3. When is it a good fit?

- You want a single tool to scan container images **and** IaC.
- You’re integrating into GitHub Actions, GitLab CI, or local dev workflows.
- You want SBOM-based scanning with SPDX/CycloneDX support.
- You need fast vulnerability detection with frequent CVE DB updates.

## ⚠️ 4. When is it not a good fit?

- You need deep analysis of private registry layers (e.g., Clair with Harbor).
- You want policy-as-code enforcement (use conftest or OPA).
- You need enterprise controls like role-based access — Trivy is CLI-first and lightweight.

## 🔐 5. How secure is it? Are there any concerns?

Trivy fetches the latest vulnerability databases frequently and runs scans without uploading your artifacts anywhere (unless you explicitly opt in). It doesn’t analyze running containers or memory — it’s a **static scanner**.

Concerns:

- False positives may occur when base image metadata is incomplete.
- Requires internet to fetch latest CVEs by default (can be configured offline).

## 📦 6. How does it integrate with Containers/Kubernetes/Cloud?

- **Containers**: Scans Docker images, Dockerfiles, and SBOMs.
- **Kubernetes**: Supports scanning manifests and Helm charts.
- **Cloud**: Scans Terraform and CloudFormation for misconfigs.

Useful in GitHub Actions, Tekton, Jenkins, or even VSCode with Trivy extension.

## ⚙️ 7. How does it actually work? (High-level flow)

1. Downloads the latest CVE database and policy rules.
2. Analyzes specified targets (images, IaC, SBOMs).
3. Matches detected packages or resources against known vulnerabilities and misconfigs.
4. Outputs results in human-readable or machine-parsable formats (JSON, table, SARIF).

## 🚀 8. Quick Start / Common Commands

Install:

```bash
brew install aquasecurity/trivy/trivy     # macOS
apt install trivy                          # Debian/Ubuntu
```

Scan a local image:

```bash
trivy image nginx:latest
```

Scan a Terraform directory:

```bash
trivy config ./terraform
```

Scan a Git repo:

```bash
trivy repo https://github.com/user/repo
```

Generate and scan an SBOM:

```bash
trivy sbom --format spdx-json --output sbom.json nginx:latest
trivy sbom --input sbom.json
```

## 🧠 9. What to learn next?

- Try scanning a real-world image (e.g., your team’s base image).
- Compare `trivy image` with `trivy sbom` for different scan depths.
- Integrate Trivy into a GitHub Action or pre-commit hook.
- Explore the `trivy k8s` plugin to scan live clusters.

---

For hybrid IaC + image pipelines, pair Trivy with Checkov to cover both misconfigs and vulnerabilities in a single pipeline.

