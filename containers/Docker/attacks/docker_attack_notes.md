# Docker Container Threat Landscape

These notes capture how attackers typically target Docker environments and what to explore next.

## Threat Landscape
- Exposed Docker daemons allow remote code execution.
- Misconfigured container privileges lead to host compromise.
- Vulnerable images introduce outdated packages and secrets.

## Attack Vectors
1. **Docker socket abuse** – Mounting `/var/run/docker.sock` grants root-equivalent control.
2. **Namespace escapes** – Bugs or capabilities letting a process leave PID or mount namespaces.
3. **Capability abuse** – Adding powerful capabilities like `SYS_ADMIN` or `NET_ADMIN`.
4. **Dangerous flags** – Running containers with `--privileged` or extensive `--cap-add`.

## Next Steps
- Develop proof-of-concept scripts for privilege escalation via the Docker socket.
- Test PID namespace escapes and monitor with ps namespace checks.
- Create auditing wrappers around `docker` to log risky operations.
