# Vulnerability Scanning Tools: Clair vs Grype vs Trivy

| Tool  | Pros | Cons |
|-------|------|------|
| **Clair** | Integrates with many registries; API-driven scanner. | Can be complex to deploy; slower updates. |
| **Grype** | Simple CLI usage; supports SBOM inputs; good distro coverage. | Limited container registry integrations. |
| **Trivy** | Fast scans; scans images, filesystems and git repos; built-in misconfig checks. | Larger binary size; advanced features require more configuration. |

All three tools output vulnerability lists in JSON format and support CVE feeds.
Grype and Trivy are easiest for local use, while Clair often runs as a service in
registries.
