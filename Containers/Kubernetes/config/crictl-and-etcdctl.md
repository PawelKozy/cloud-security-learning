# 🔧 Kubernetes Node-Level Debugging with `crictl` and `etcdctl`

This guide outlines the usage of two critical tools for node-level inspection in Kubernetes environments:  
- `crictl`: CLI tool for interfacing with container runtimes (containerd, CRI-O)  
- `etcdctl`: CLI for querying etcd, Kubernetes' backing key-value store

They’re especially valuable in scenarios where the control plane is degraded or inaccessible.

---

## 🛠️ `crictl`: Container Runtime Interface CLI

`crictl` allows direct interaction with CRI-compliant container runtimes like containerd and CRI-O, bypassing the Kubernetes API. It’s invaluable when `kubectl` is unusable (e.g., node isolation, kubelet/API server down) or for inspecting system-managed components like `etcd`, `kube-apiserver`, etc.

### 🔍 Essential `crictl` Commands

```bash
# List all containers (including non-Kubernetes ones)
crictl ps -a

# View images used on the node
crictl images

# Inspect details about a container
crictl inspect <container-id>

# Get container logs
crictl logs <container-id>

# Exec into container runtime directly
crictl exec -it <container-id> sh
```

🧠 **Notes**
- `crictl` communicates directly with the container runtime, not Docker.
- You can inspect static system pods like `kubelet`, `etcd`, `kube-apiserver` even if the cluster API is unavailable.
- You can also use `crictl pods` and `crictl stats` for basic pod info and runtime metrics.

## 📦 `etcdctl`: Inspecting Kubernetes Backend Data
Kubernetes stores its cluster state in etcd. The `etcdctl` command-line utility allows direct interaction with etcd for data inspection, debugging, and operational checks.

Always use `ETCDCTL_API=3` with modern Kubernetes.

### 🔐 Verifying Secret Encryption at Rest
To ensure secrets are encrypted in etcd (and not stored in plaintext):

1. **Create a test secret**
   ```bash
   kubectl create secret generic test-secret --from-literal=password=S3cr3t123
   ```
2. **Find the etcd container on the node**
   ```bash
   crictl ps -a | grep etcd
   ```
3. **Exec into the etcd container**
   ```bash
   crictl exec -it <etcd-container-id> sh
   ```
4. **Query the raw key**
   ```bash
   ETCDCTL_API=3 etcdctl get /registry/secrets/default/test-secret \
     --endpoints=https://127.0.0.1:2379 \
     --cacert=/etc/kubernetes/pki/etcd/ca.crt \
     --cert=/etc/kubernetes/pki/etcd/server.crt \
     --key=/etc/kubernetes/pki/etcd/server.key | hexdump -C | less
   ```
   The binary (encrypted) output confirms encryption is enabled. If it’s plaintext, double-check your encryption provider configuration in `EncryptionConfiguration`.

If the terminal gets corrupted, run:
```bash
reset
```

### 📚 Useful `etcdctl` Commands
```bash
# List all keys
etcdctl get "" --prefix --keys-only

# Read a specific key
etcdctl get /registry/pods/default/nginx

# Put a new key
etcdctl put /debug/foo bar

# Delete a key
etcdctl del /debug/foo
```

### 🔐 Certificate Auth Reminder
Ensure all commands include the appropriate certs:

- `--cacert`: CA for etcd
- `--cert`: client certificate
- `--key`: client private key

These files are typically under: `/etc/kubernetes/pki/etcd/`

## 🧪 Use Cases Beyond Secret Encryption
- **Manual state inspection** — Get raw values for Kubernetes resources (Pods, Deployments) from etcd for debugging.
- **Disaster recovery** — Directly read/write critical keys when rebuilding the cluster.
- **Data drift validation** — Compare actual etcd values vs. `kubectl get` output when API server behavior seems off.
- **Etcd health and performance checks** — Use with `etcdctl endpoint health`, `etcdctl alarm list`, `etcdctl defrag`.

## 🔁 Reflections
- Can you confidently inspect secrets, pod definitions, and static control plane components without using `kubectl`?
- How would you troubleshoot a broken cluster where `kubectl` times out?
- How often do you test etcd backup/restore and encryption validation in your cluster lifecycle?

## 🔗 Next Steps
Try running `crictl` and `etcdctl` during a simulated control plane failure.
