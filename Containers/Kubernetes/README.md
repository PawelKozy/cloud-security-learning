# Kubernetes: Container Orchestration Overview 🌐⚙

## Introduction
Kubernetes is a container orchestration platform that helps manage and automate the deployment, scaling, and operations of application containers across clusters of hosts. It provides a unified API to define how applications should run, and continuously works to match the actual system state with the user-defined desired state. This approach makes it easier to operate distributed systems in a consistent, repeatable manner. 🧭📘🛠️

---

## Core Control Plane Components 🚀

### 1. API Server (`kube-apiserver`)
The API Server is the central access point to a Kubernetes cluster. All user interactions—whether from `kubectl`, dashboards, or internal components—go through this server. It processes REST requests, validates inputs, and updates the cluster state by communicating with etcd, the cluster's key-value store.

**Key Functions:**
- Validates and configures API objects such as pods and services.
- Acts as the gateway for both human and machine interaction.
- Uses authentication and authorization mechanisms (like RBAC).

**Security Best Practices:**
- Turn on auditing to track API activity.
- Use TLS and restrict unauthenticated access.
- Apply least privilege with fine-grained roles.

```bash
kubectl auth can-i create pods --as user@example.com
```

---

### 2. Controller Manager (`kube-controller-manager`)
The controller manager runs background processes called controllers that ensure the cluster state matches the desired configuration. For example, the replication controller ensures the requested number of pod replicas are running at all times.

**Common Controllers:**
- Node controller: Monitors node availability.
- ReplicaSet controller: Maintains pod counts.
- ServiceAccount controller: Ensures service accounts exist in each namespace.

**Security Note:**
If misconfigured, controllers can unintentionally create or delete resources, so auditing and role restrictions are important.

---

### 3. Cloud Controller Manager
In cloud environments, this component handles integration with the underlying infrastructure, like attaching volumes, assigning IPs, or setting up load balancers.

**Key Roles:**
- Works with cloud APIs for resource provisioning.
- Decouples cloud logic from core Kubernetes.

**Security Tip:**
- Only grant necessary cloud permissions.
- Avoid exposing metadata endpoints to workloads.

---

### 4. Scheduler (`kube-scheduler`)
The scheduler decides which node a new pod should run on, based on resource availability, affinity rules, and constraints. It does not start the pod but records its decision in the API server, and the kubelet acts on it.

**Scheduling Factors:**
- CPU, memory availability.
- Taints and tolerations.
- Node and pod affinity/anti-affinity.

**Example:**
```yaml
spec:
  priorityClassName: high-priority
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - critical
```

---

### 5. etcd
etcd is a distributed key-value store used to persist the state of the entire Kubernetes cluster. It stores information like config maps, secrets, and workload definitions. Kubernetes uses the RAFT consensus algorithm to ensure consistency.

**Security Considerations:**
- Encrypt sensitive data at rest.
- Secure etcd with mutual TLS.
- Backup regularly.

```yaml
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - kms:
          name: aws-kms
          endpoint: https://kms.us-east-1.amazonaws.com
      - identity: {}
```

---

## Node-Level Components 🔧

### 6. kubelet
The kubelet is the agent that runs on each node. It receives instructions from the API server and ensures that the defined containers are running and healthy. It interacts with the container runtime like containerd or CRI-O.

**Security Practices:**
- Restrict access to the kubelet API.
- Use AppArmor and seccomp for container isolation.
- Enable logging to track behavior.

---

### 7. kube-proxy
kube-proxy is responsible for networking at the node level. It uses `iptables` or IPVS rules to route traffic from services to the correct pod endpoints.

**Enhancements:**
- Replace kube-proxy with Cilium for better observability.
- Apply network policies for traffic segmentation.

---

## Workload Abstractions 📦

### Pods
A pod is the smallest deployable unit in Kubernetes and can contain one or more containers. All containers in a pod share the same IP address, hostname, and storage volumes.

### ReplicaSet & Deployment
A ReplicaSet ensures that a specific number of pod replicas are always running. A Deployment manages ReplicaSets and supports updates and rollbacks.

```bash
kubectl rollout history deployment backend-api
```

### DaemonSet
A DaemonSet ensures that a copy of a specific pod runs on every node (or a subset). This is common for monitoring and security agents.

### StatefulSet
A StatefulSet is used for stateful applications. It provides persistent storage and stable network identities for each pod.

### InitContainers
Init containers run before the main application containers start. They are used for initialization tasks like waiting for services or setting up configuration.

```yaml
initContainers:
  - name: migrate-db
    image: flyway/flyway
    args: ["migrate"]
```

---

## Cluster Organization 🏷️

### Namespaces
Namespaces let you divide a Kubernetes cluster into logical groups. You can use them to separate environments like dev and prod, or to isolate different teams.

```bash
kubectl get resourcequotas -n tenant-1
```

### Services
Services expose pods as a stable endpoint for communication. Kubernetes offers several service types:

| Type          | Description                                  |
|---------------|----------------------------------------------|
| ClusterIP     | Internal-only access                         |
| NodePort      | Exposes service on a port on each node       |
| LoadBalancer  | Uses cloud provider’s external load balancer |

---

## Networking 🛜

### Network Plugins (CNI)
CNI plugins manage how pods are assigned IPs and how network traffic flows in the cluster. They enable features like service discovery, policy enforcement, and load balancing.

| Plugin  | Highlights                                 |
|---------|---------------------------------------------|
| Calico  | Rich policy engine, supports BGP and eBPF  |
| Cilium  | Based on eBPF, L3–L7 visibility             |
| Flannel | Lightweight overlay, good for test clusters|

**Tip:** Choose plugins like Cilium or Calico for production workloads with strong security needs.

---

### Ingress
Ingress resources define rules for routing HTTP(S) traffic to services. They require an Ingress controller (e.g., NGINX, Traefik) to work.

**Features:**
- TLS termination
- Path and host-based routing
- Rate limiting (depends on controller)

```yaml
spec:
  tls:
    - hosts:
        - app.example.com
      secretName: app-cert
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /admin
            pathType: Prefix
            backend:
              service:
                name: admin-api
                port:
                  number: 443
```

---

## Reflection Prompts 🧠
- How would you harden the API server against unauthorized use?
- What could go wrong if your Ingress rules are too permissive?
- How can you detect unusual behavior using audit logs or eBPF?
- Which network plugin gives you the best visibility and why?

---

## Tools and Next Steps 🛠📋⚙
- `kube-bench`: Tests compliance with CIS benchmarks.
- `kubeaudit`: Identifies insecure Kubernetes settings.
- `kyverno` / `OPA`: Enforce security and governance policies.
- `trivy`, `grype`: Scan container images for vulnerabilities.
- `k9s`, `kubectl sniff`: Help debug, monitor, and inspect traffic.

---

## Summary 📌
Kubernetes simplifies the deployment and operation of complex container-based systems. By understanding its core components and abstractions, you can build more secure, scalable, and resilient applications. Security plays a key role—from admission controls to runtime isolation—and mastering these areas will prepare you for advanced cloud-native engineering work.

