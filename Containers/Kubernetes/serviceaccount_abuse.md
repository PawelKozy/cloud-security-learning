# Abusing Kubernetes ServiceAccounts for Escalation

In Kubernetes, ServiceAccount (SA) tokens are the default method for in-cluster authentication to the Kubernetes API. These tokens, if not tightly scoped and managed, become a key target for attackers looking to escalate privileges, pivot, or exfiltrate data after gaining initial access to a container.

This document focuses on how attackers abuse SA tokens in real-world scenarios and how this can lead to cluster-wide compromise.

---

## 🎯 Why Attackers Target ServiceAccounts

- Every pod by default receives a mounted SA token.
- These tokens grant authenticated access to the Kubernetes API.
- Misconfigured RBAC or overly permissive roles can allow attackers to:
  - Escalate privileges
  - Read secrets
  - Deploy malicious pods
  - Discover the entire cluster topology

---

## 🔍 Reconnaissance from Within a Compromised Pod

### 1. Check if a Token is Mounted
```bash
ls /var/run/secrets/kubernetes.io/serviceaccount/
```
If the token exists, it can be used to access the API.

### 2. Read the Token and CA
```bash
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
APISERVER=https://kubernetes.default.svc
```

### 3. Interact with the Kubernetes API
```bash
curl -s --cacert $CACERT \
  -H "Authorization: Bearer $TOKEN" \
  $APISERVER/api
```

### 4. Discover Permissions
```bash
kubectl auth can-i --as=system:serviceaccount:<namespace>:<sa-name> --list
```
> This requires kubectl to be installed in the container, or copied in.

Alternative (raw API):
```bash
curl -s --cacert $CACERT -H "Authorization: Bearer $TOKEN" \
  $APISERVER/apis/rbac.authorization.k8s.io/v1/clusterrolebindings
```
---

## 🚨 Common Privilege Escalation Paths

### 🧬 Access Secrets
```bash
kubectl get secrets --all-namespaces
```
Look for:
- kubeconfig tokens
- cloud provider creds
- database passwords

### 🚀 Create or Modify Workloads
If the SA has rights to create deployments or CronJobs:
```bash
kubectl patch deployment legitimate-app -p '...'
```
Inject a reverse shell, crypto miner, or imagePull from malicious registry.

### 🛠 Abuse RoleBindings
If you can create RoleBindings:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: escalate-me
  namespace: default
subjects:
- kind: ServiceAccount
  name: attacker-sa
  namespace: default
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

### 🏹 Access Other Pods or Exec
```bash
kubectl get pods -A
kubectl exec -it some-pod -- /bin/sh
```

---
## 📋 What to Look For

### 1. SA-to-API Communication

Enable **Kubernetes Audit Logs** and inspect for API calls authenticated via `system:serviceaccount:<namespace>:<sa-name>`.

#### Key Signals:

- `get`, `list`, or `watch` on secrets, configmaps, or pods in other namespaces
- `create`, `patch`, or `delete` deployments, jobs, pods
- RoleBinding or ClusterRoleBinding creation/modification

### 2. High-Risk Calls from Default SAs

Audit for usage of the default SA in sensitive namespaces:

```bash
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.name}:{.spec.serviceAccountName}{"\n"}{end}' | grep ':default'
```

### 3. Cross-Namespace Activity

Check for SAs making calls outside their own namespace (e.g., `default` SA in `dev` namespace modifying resources in `prod`).

### 4. Workload Manipulation

If an SA can patch or update Deployments, it may be used to inject malicious containers:

```yaml
requestURI: "/apis/apps/v1/namespaces/prod/deployments/webapp"
verb: "patch"
authenticatedUser: "system:serviceaccount:dev:ci-runner"
```

---

## ⚙️ How to Enable Audit Logs

In kube-apiserver config (e.g., `/etc/kubernetes/manifests/kube-apiserver.yaml`), add:

```yaml
--audit-log-path=/var/log/k8s-audit.log
--audit-policy-file=/etc/kubernetes/audit-policy.yaml
```

Example audit policy:

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    users: ["system:serviceaccount:"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    resources:
    - group: ""
      resources: ["pods", "secrets", "configmaps"]
    - group: "rbac.authorization.k8s.io"
      resources: ["roles", "rolebindings", "clusterrolebindings"]
```

---

## 🧪 Example Queries for Centralized Logging

If you send audit logs to a SIEM or log aggregator:

### Detect SA reading secrets

```kql
k8s_audit
| where user.username startswith "system:serviceaccount:"
| where verb == "get" and objectRef.resource == "secrets"
```

### Detect RoleBinding creation

```kql
k8s_audit
| where user.username startswith "system:serviceaccount:"
| where objectRef.resource has "rolebinding" and verb in ("create", "patch")
```

### SA interacting with resources in another namespace

```kql
| where user.username startswith "system:serviceaccount:"
| extend ns=split(user.username, ":")[2]
| where ns != objectRef.namespace
```

---

## 🧱 Defensive Considerations
- Enable `BoundServiceAccountTokenVolume` and short-lived tokens
- Set `automountServiceAccountToken: false` where possible
- Use minimal RBAC roles per SA
- Monitor audit logs for SA abuse patterns

---

## 🧪 Detection Tips
- Access to secrets from service accounts outside kube-system or monitoring namespaces
- API calls from a namespace modifying unrelated deployments
- RoleBindings to powerful roles from unexpected pods or users

---

## 📌 Summary
Even without a container breakout, a single misconfigured ServiceAccount can open the door to full cluster takeover. Defensive engineering and constant RBAC review are critical to prevent SA abuse.

---

## 🔗 References
- [Kubernetes: Configure Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [Kubernetes API Access from Pods](https://kubernetes.io/docs/concepts/architecture/authentication/#service-account-tokens)
- [kubectl auth can-i](https://kubernetes.io/docs/reference/access-authn-authz/authorization/#checking-api-access)

