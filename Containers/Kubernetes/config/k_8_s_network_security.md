# Kubernetes Network Security

This document provides a comprehensive overview of Kubernetes network security mechanisms and best practices. It focuses on container networking models, enforcement layers, common risks, and real-world tooling.

---

## 1. Pod Networking Fundamentals

### Pod-to-Pod Communication

- Every Pod in a Kubernetes cluster receives a unique IP address.
- Pods can communicate **without NAT** across nodes in the same cluster.
- On the same node, communication typically goes through a **virtual bridge** (e.g., `cni0`), and across nodes via **routing tables** or **VXLAN tunnels**.

### Network Namespaces

- Each Pod runs in its own **network namespace**.
- This isolates interfaces, routing tables, and firewall rules.
- Containers in the same Pod share a network namespace and can communicate via localhost.

---

## 2. Container Network Interfaces (CNI)

Kubernetes relies on the CNI specification to provide network connectivity for Pods. Key plugins include:

### Flannel

- **Mode**: Layer 2 (VXLAN) or host-gateway.
- **Purpose**: Simple overlay network; no native support for NetworkPolicies.
- **Use Case**: Lightweight networking in small-to-medium clusters.

### Calico

- **Mode**: L3 routing with optional eBPF dataplane.
- **Features**: Rich NetworkPolicy support, IP-in-IP tunneling, WireGuard encryption.
- **Use Case**: Performance-focused environments with high policy demands.

### Cilium

- **Mode**: eBPF-based L3/L4 and L7 enforcement.
- **Features**: Identity-aware policies, API-aware visibility, Envoy integration.
- **Use Case**: Advanced microsegmentation, observability, and zero trust models.

### Weave Net

- **Mode**: Layer 2 overlay.
- **Features**: Simplicity and automatic encryption.
- **Use Case**: Development and smaller teams seeking ease of use.

> **Note**: Choice of CNI impacts policy capabilities and performance. Some CNIs (e.g., Flannel) require chaining with another plugin (e.g., Calico) for security enforcement.

---

## 3. Network Policies

Kubernetes supports declarative network policies to control traffic between Pods.

### Key Concepts

- **Namespace-scoped**: Policies apply to Pods within a given namespace.
- **Selectors**: Define affected Pods (via `podSelector`, `namespaceSelector`).
- **Rules**: Specify `ingress` and `egress` behavior using:
  - IP blocks
  - Pod labels
  - Ports and protocols

### Example

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-traffic
spec:
  podSelector:
    matchLabels:
      role: backend
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### Enforcement Caveats

- No-op unless supported by the CNI plugin.
- Default behavior is to allow all traffic unless restricted.

---

## 4. Common Threats & Mitigations

### Threat: Lateral Movement

- **Risk**: A compromised Pod can freely access internal services.
- **Mitigation**:
  - Define restrictive NetworkPolicies
  - Enforce least privilege at the network level

### Threat: DNS Spoofing

- **Risk**: Pods resolving malicious domains due to ARP cache poisoning.
- **Mitigation**:
  - Drop capabilities like `CAP_NET_RAW`
  - Use runtime constraints and Seccomp profiles

### Threat: Eavesdropping

- **Risk**: Inter-Pod traffic being sniffed via tcpdump or host network access.
- **Mitigation**:
  - Encrypt traffic using TLS or WireGuard (e.g., Calico)
  - Avoid `hostNetwork: true` unless necessary

---

## 5. Runtime Enforcement Tools

### Falco

- **Method**: Kernel-level syscall monitoring via eBPF or driver.
- **Focus**: Detects abnormal behavior (e.g., unexpected network access).
- **Deployment**: Runs as DaemonSet on each node.

### Cilium Hubble

- **Method**: L7-aware visibility using eBPF datapath.
- **Focus**: Provides audit trails for service-to-service communication.

### Kubernetes Audit Logs + Admission Controllers

- Validate security-sensitive configurations (e.g., dropping dangerous capabilities).

---

## 6. DNS & CoreDNS

- CoreDNS is the default DNS provider in most Kubernetes clusters.
- DNS is often used for service discovery.

**Security Tips**:

- Limit egress from Pods to trusted DNS servers.
- Monitor abnormal DNS queries (e.g., large volumes to external domains).

---

## 7. Linux Kernel Features

Kubernetes networking leans on Linux primitives:

- **iptables/nftables**: For routing, NAT, and basic firewalling.
- **tc / eBPF hooks**: For advanced filtering and metrics.
- **cgroups + namespaces**: Isolate traffic and processes per container.

---

## 8. Network Observability Tools

- `netstat`, `ss`, `tcpdump`, `iftop`: Legacy tools for node-level observation.
- `pscap -a`: Lists process capabilities to identify risk (e.g., `CAP_NET_RAW`).
- `crictl inspect` + `ctr`: Container runtime-level inspection.
- Prometheus + Grafana: Visualize network throughput and error rates.

---

## 9. Best Practices Summary

| Area                      | Recommendation                                               |
| ------------------------- | ------------------------------------------------------------ |
| **Pod Isolation**         | Use NetworkPolicies to restrict communication                |
| **Traffic Encryption**    | Enforce TLS or encrypted overlays like WireGuard             |
| **Capability Management** | Drop `CAP_NET_RAW`, `CAP_NET_ADMIN` unless needed            |
| **Monitoring**            | Deploy Falco or Cilium with Hubble for runtime observability |
| **Policy Validation**     | Use Gatekeeper or Kyverno to block insecure specs            |
| **Host Networking**       | Avoid unless explicitly required                             |

