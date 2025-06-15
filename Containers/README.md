# 🧱 Containers: Security & Best Practices

This section focuses on securing and hardening container-based environments. Explore best practices for image creation, runtime protection, orchestration, and scanning.

---

## 📁 Topics

### 🐳 [Docker](./Docker/)
Covers foundational concepts and security concerns related to Docker containers, including how containers interact with the host, common misconfigurations, and best practices for isolation and image usage.

### ☸️ [Kubernetes](./Kubernetes/)
Focuses on securing Kubernetes workloads through pod-level controls, admission controllers, runtime protection, and policy frameworks. See the [dedicated Kubernetes README](./Kubernetes/README.md) for an in-depth overview.

---

## 🚧 Roadmap & Ideas

This section will grow to include advanced tooling and runtime protection strategies:

- 🔬 **Runtime visibility tools** (e.g., Falco, Sysdig, Tracee) — to observe and alert on container behavior at runtime.
- 🧠 **eBPF-based detections** — leveraging kernel-level observability to detect anomalies and advanced threats.
- 📦 **Container signing & verification** — best practices for image integrity with tools like `cosign` and `Notary v2`.
- 🛡️ **Security automation in CI/CD** — integrating scanners and policies into build pipelines.

Contributions and topic suggestions are always welcome!

