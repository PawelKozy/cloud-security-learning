# Container Network & Volume Security

## 📘 Intro

Misconfigured container networking and volume handling can lead to lateral movement, privilege escalation, and data exposure. This document covers common risks and best practices related to open ports, Docker socket exposure, network segmentation, and volume security.

---

## 🌐 Core Concepts: Container Network Security

### 🔓 Common Risks

- **Open Ports**: Unnecessary exposed ports increase attack surface.
- **Container-to-Container Traffic**: By default, communication is unencrypted and unrestricted.
- **Exposed Docker Socket**: Mounting `/var/run/docker.sock` gives full control over the Docker host — equivalent to root access.
- **Host Path Mounts**: Sharing sensitive host directories with containers can enable data tampering or host compromise.
- **Shared Volumes**: Used for inter-container communication, but if not secured, allow lateral movement.

### 🔐 Network Isolation Best Practices

- **Use Custom Networks**: Avoid the default `bridge` network; create custom networks with clear boundaries.
- **Avoid Host Networking**: `--network=host` removes isolation.
- **Disable ICC (Inter-Container Communication)**:
  ```bash
  "icc": false  # in Docker daemon.json
  ```
- **Segment Networks**:
  - Separate frontend and backend containers.
  - Use API services to mediate access.
- **Use mTLS or Service Meshes**:
  - Istio, Linkerd: Enable mTLS between pods.
  - Cilium with WireGuard/IPSec for transparent encryption.
- **Drop Capabilities**:
  - Disable capabilities like `NET_RAW`:
    ```bash
    docker run --cap-drop=NET_RAW
    ```
- **Logging & Monitoring**:
  - Log all inter-container communication.
  - Monitor suspicious traffic between containers.
  - Detect unauthorized connection attempts using tools like Falco or Cilium Hubble.

### 🧩 Encryption Summary

| Communication Path                | Encrypted by Default? | How to Encrypt                                            |
| --------------------------------- | --------------------- | --------------------------------------------------------- |
| Docker API (Unix socket)          | ❌                     | Use TLS with `--tlsverify`                                |
| Docker API (TCP port)             | ❌                     | Use TLS, never expose on `0.0.0.0:2375`                   |
| Pod-to-Pod (K8s)                  | ❌                     | Use service mesh (Istio, Linkerd), or CNI with encryption |
| K8s API Server                    | ✅                     | Uses HTTPS and authentication                             |
| Container-to-Container (same pod) | ❌                     | Shared localhost – not encrypted                          |

---

## 📦 Volume Security

### 🔐 Key Security Concerns

- **Excessive Permissions**: Containers with write access to volumes can tamper with data or host files.
- **Secrets Exposure**: Mounting secrets without access controls exposes sensitive info.
- **Host Filesystem Access**: `-v /:/host` can give root container access to the entire host.
- **Persistent Data Risk**: Attackers can modify data in shared volumes.

### ✅ Best Practices

- **Use Read-Only Mounts**:
  ```bash
  -v $(pwd)/config:/app/secrets:ro
  ```
- **Restrict Host Paths**: Avoid mounting system directories unless absolutely needed.
- **Avoid Mounting docker.sock**: Never expose Docker socket to untrusted containers.
- **Temporary Writable Storage with **``:
  ```bash
  docker run --read-only \
    --tmpfs /tmp \
    -v $(pwd)/secure-config:/app/secrets:ro \
    secure-volume-app
  ```
- **Use Non-Privileged Users**: Run containers as a dedicated non-root user with limited permissions.
- **Encrypt Volumes (Kubernetes)**: Use CSI drivers and enforce volume policies that support encryption at rest.

---

## 🔧 Tools

- **Falco**: Detects unexpected behavior like sensitive mount access.
- **Cilium**: Provides identity-aware networking and observability.
- **AppArmor / Seccomp**: Restrict system calls and enforce volume policies.
- **Service Meshes (Istio, Linkerd)**: Add mTLS and traffic control between services.

---

## 💡 Reflections

- What’s the implication of exposing the Docker socket in a multi-tenant environment?
- If your containers can talk to each other freely, how would an attacker move laterally?
- Are your secrets protected when stored in mounted volumes?
- Have you tested how traffic is encrypted between your services — or assumed it's encrypted?

---

## ✅ Conclusion

Network and volume misconfigurations are among the most common and critical container security risks. By applying segmentation, denying unnecessary communication, enforcing encryption, and using secure volume mounts, you reduce your attack surface and prevent lateral movement and privilege escalation.

Apply these principles continuously in CI/CD pipelines, test environments, and production. Security should be enforced by default, not added as an afterthought.

