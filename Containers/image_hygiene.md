# 🧼 Container Image Hygiene Best Practices

Secure container workloads start with secure images. Poor image hygiene can lead to vulnerabilities, credential leaks, bloated attack surfaces, and unstable builds. This guide outlines best practices for building, maintaining, and validating secure container images.

---

## 🛠️ Image Build Best Practices

### ✅ Use Minimal Base Images

- Use `distroless`, `alpine`, or custom scratch-based images
- Avoid large distributions (e.g., full Debian, Ubuntu) unless required
- Benefits: smaller attack surface, faster builds, fewer vulnerabilities

### ✅ Pin Image Digests

- Avoid using `latest` or floating tags

```dockerfile
FROM python:3.11.5@sha256:<digest>
```

- Ensures immutability and reproducibility of builds

### ✅ Multi-stage Builds

- Separate build-time tools from final runtime image

```dockerfile
FROM golang:1.21 as builder
WORKDIR /app
COPY . .
RUN go build -o app

FROM distroless/static
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
```

- Keeps final image lean and secure

### ✅ Avoid Secrets in Dockerfiles

- Never hardcode secrets, tokens, or credentials
- Use build-time variables (`--build-arg`) or external secret management

### ✅ Use .dockerignore

- Exclude unnecessary files (e.g., `.git`, `node_modules`) from context

```dockerignore
.git
*.pem
.env
node_modules/
```

---

## 🔐 Image Content Security

### 🧪 Scan Images for Vulnerabilities

- Use tools like:
  - `Trivy`
  - `Grype`
  - `Clair`
  - GitHub's Dependabot (for Dockerfiles)
- Scan both OS packages and language-level deps (e.g., pip, npm)

### 🧬 Analyze for Misconfigurations

- Check for dangerous instructions:
  - `ADD` instead of `COPY`
  - Running as root
  - Unpinned packages
  - Exposed ports

### 👤 Run as Non-Root

Add to your Dockerfile or Kubernetes manifest:

```dockerfile
USER 1001
```

Or in Kubernetes:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
```

### 🧹 Clean Up After Install

- Remove unnecessary build tools or caches

```dockerfile
RUN apt-get update && apt-get install -y build-essential \
    && make \
    && apt-get purge -y build-essential \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
```

---

## 📦 Registry Hygiene

### 🔒 Use Private Registries When Possible

- Prevents public scraping of potentially sensitive builds
- Enforce access controls and audit logging

### 🧯 Sign and Verify Images

- Use **Sigstore** (`cosign`) or **Notary v2** to sign images
- Integrate image verification into admission control:

```yaml
policy:
  images:
    requireSignature: true
```

### 📜 Set Retention & Tagging Policies

- Avoid clutter and stale images
- Tag images semantically (`app:v1.0.1`)
- Use lifecycle policies to prune unused builds

---

## 🧪 Runtime Hardening via Image Settings

### 🛑 Read-Only Filesystem

```yaml
securityContext:
  readOnlyRootFilesystem: true
```

### ✂️ Drop Unused Capabilities

```yaml
securityContext:
  capabilities:
    drop: ["ALL"]
```

### 🔎 Set EntryPoint Explicitly

- Avoid relying on base image `CMD`

```dockerfile
ENTRYPOINT ["/usr/local/bin/app"]
```

\
Following strong image hygiene practices is a foundational step in securing containerized workloads. It not only improves security but also enhances performance, observability, and maintainability across the SDLC.

