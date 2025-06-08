# Dangerous Docker Run Flags

- `--privileged` grants all capabilities and disables many security mechanisms.
- `--cap-add=SYS_ADMIN` exposes host devices and allows numerous escapes.
- `-v /:/host` mounts the host root filesystem, often leading to full compromise.
