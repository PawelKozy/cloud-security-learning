# Container Image Hygiene

These notes outline minimal image practices, scanning workflows, and runtime observability techniques.

## Image Minimization

- Prefer distroless or other minimal base images to reduce attack surface.
- Use multi-stage builds so that compilers and tooling never ship in the final image.
- Tools like `docker-slim` can remove unused binaries and generate seccomp profiles.

Example multi-stage Dockerfile:

```Dockerfile
FROM golang:1.21 AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /app

FROM gcr.io/distroless/static
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
```

## Secrets Management

- Never bake credentials into Dockerfiles.
- Inject secrets at runtime via environment variables or mounted files.

## Vulnerability Scanning

Run scanners during CI to catch issues before deployment.
Example using Trivy:

```bash
trivy image --severity HIGH,CRITICAL --exit-code 1 my-image:latest
```

Other tools include Grype and Clair.

## Runtime Observability

`osquery` can inspect running containers via SQL-like queries. Useful checks include detecting privileged containers, host path mounts, and exposed secrets.
See the SQL files in `../osquery/` for sample policies.
