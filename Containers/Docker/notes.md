# Container Security Principles

Containerized environments introduce new attack surfaces and isolation boundaries that must be protected through layered defense. This document outlines host protections, daemon security, and runtime defenses.

## Host-Based Protections

### Create a Separate Partition for Containers
Isolate container storage (e.g., `/var/lib/docker`) on a dedicated partition to prevent containers from filling up system-critical storage. This containment mitigates denial-of-service attacks via disk exhaustion and improves auditability and cleanup.

### Harden the Container Host
Apply standard OS hardening practices:

- Disable unused services
- Enable SELinux or AppArmor
- Enforce strict file permissions
- Use minimal base OS images such as Ubuntu Minimal or Alpine
- Follow CIS Benchmarks for Docker or Kubernetes as a baseline

### Keep Docker Up to Date
Patch known vulnerabilities in the Docker Engine and related tooling. Track advisories from Docker CVE feeds and apply updates regularly, ideally through automation.

### Only Allow Trusted Users to Control the Docker Daemon
The Docker daemon (`dockerd`) runs with root privileges. Any user in the `docker` group effectively gains root access on the host. Enforce strict RBAC and avoid broad group-based elevation where possible.

### Audit Docker Daemon, Docker Files, and Directories
Continuously monitor access and changes to:

- Docker socket (`/var/run/docker.sock`)
- Dockerfiles in code repositories
- Image build logs and metadata

Integrate host-based auditing tools such as `auditd` or `osquery` and centralize logs via a SIEM.

## Daemon Security Mechanisms

### Restrict Network Traffic Between Containers
Use Docker's `--icc=false` flag or Kubernetes NetworkPolicies to control inter-container communication. Isolate sensitive workloads and prevent lateral movement within the container network.

### Do Not Use Insecure Registries
Disable registries served over plain HTTP. Always pull images from trusted, signed, and TLS-enabled registries. Consider enforcing `--disable-legacy-registry` and implement image signature verification with tools like Notary or Cosign.

### Enable User Namespace Support
Enable user namespaces to map the root user inside the container to an unprivileged UID on the host. This significantly reduces the impact of a container breakout.

### Configure TLS Authentication for the Docker Daemon
Secure Docker API endpoints with TLS and client certificates, especially when enabling remote management. Avoid exposing the Docker socket over TCP without authentication.

## Container Security Engineering

### Runtime Protections for Containers
Deploy monitoring and enforcement tools such as:

- eBPF-based solutions (Cilium, Tracee, Falco)
- File Integrity Monitoring for container layers
- Process and syscall controls via AppArmor, SELinux, or Seccomp profiles

These tools help detect anomalies like privilege escalation attempts, unexpected shell invocation, unauthorized outbound traffic, and suspicious file modifications.

### Image Hardening and Minimalism

- Use minimal base images (for example, distroless or Alpine)
- Avoid unnecessary packages or debugging tools
- Pin specific image digests rather than relying on `latest`

### Supply Chain Security

- Scan images with tools such as Trivy, Grype, or AWS Inspector
- Validate Software Bills of Materials (SBOMs)
- Monitor registries for tampering

### Secrets Management

- Do not bake secrets into images
- Leverage services like AWS Secrets Manager, HashiCorp Vault, or Kubernetes secrets (with encryption at rest)
- Scan for exposed secrets using tools like Gitleaks
