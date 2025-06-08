# Docker Escape Cheatsheet

- Abuse the Docker socket if mounted.
- Exploit kernel vulnerabilities from privileged containers.
- Leverage capabilities like `SYS_PTRACE` or `SYS_MODULE` when available.
- Check for sensitive mounts such as the host root or `/proc`.
