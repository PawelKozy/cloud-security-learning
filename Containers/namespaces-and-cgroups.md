###🧱 Namespaces and Cgroups in Docker Security
##🔹 Namespaces: Isolated Environments for Processes
Linux namespaces isolate container resources from the host and other containers. Docker uses multiple types of namespaces by default:

| Namespace Type | Isolated by Default | Description |
|---------------|--------------------|-------------|
| PID | ✅ | Each container sees only its own processes. |
| NET | ✅ | Isolated network stack with its own IP, routes. |
| MNT | ✅ | Isolated filesystem mount points. |
| IPC | ✅ | Isolated shared memory and semaphores. |
| UTS | ✅ | Separate hostname and domain name. |
| USER | ❌ | Not isolated unless userns-remap is configured. |

By default, containers do not use user namespace remapping, meaning root inside the container is also root on the host — a risk in case of breakout.

##🛡️ Understanding User Namespace Remapping
User namespace remapping maps container root (UID 0) to an unprivileged UID on the host (e.g. UID 100000), strengthening isolation:

| Container UID | Host UID |
|---------------|---------|
| 0 (root) | 100000 |
| 1 | 100001 |
| ... | ... |

This mapping is defined in:
- `/etc/subuid`
- `/etc/subgid`

##🔄 Practical Benefits
- Even if compromised, a container root cannot affect the host.
- Prevents privileged operations like mounting filesystems or accessing host files.

##🧪 How to Verify Remapping
```bash
docker exec test-userns id
# uid=0(root) gid=0(root)

docker exec test-userns cat /proc/self/uid_map
# Shows: 0 100000 65536

ps aux | grep $(docker inspect --format '{{.State.Pid}}' test-userns)
# Shows UID 100000 on host
```

##🧠 Docker Default Behavior
```bash
docker run -d --name secure-container alpine sleep 1d
```

##🧩 Namespaces
When you run the container above, Docker isolates:

- PID, UTS, IPC, MNT, NET → ✅ Isolated by default
- USER → ❌ Not isolated unless configured
- CGROUP → ✅ Isolated

Inspect namespaces:
```bash
PID=$(docker inspect --format '{{.State.Pid}}' secure-container)
ls -l /proc/$PID/ns
```

###🧰 Control Groups (Cgroups): Enforcing Resource Limits
Docker uses cgroups to limit and isolate container resources:

| Resource | Example Flag | Description |
|---------|--------------|-------------|
| CPU | --cpus="0.5" | Limits to 50% of 1 core |
| CPU Shares | --cpu-shares=512 | Relative CPU priority |
| Memory | --memory="256m" | Restricts RAM usage |
| Swap | --memory-swap="512m" | RAM + swap usage limit |
| PIDs | --pids-limit=20 | Caps number of processes |

Check cgroup usage:
```bash
cat /proc/$PID/cgroup
# Example output: 0::/docker/<container_id>
```

##⚠️ Why This Matters
Without limits:

- A container can use 800% CPU (on 8-core systems)
- Can allocate GBs of RAM → may trigger host OOM killer
- Can spawn infinite processes → risk of fork bombs

##📈 Monitoring & Enforcement
- `docker stats` → Live usage overview
- `docker inspect` → Runtime config details
- `/proc/<pid>/cgroup` → Cgroup mapping
- `auditd`, cgroups v2 → Kernel-level monitoring

##✅ Key Takeaways
- Namespaces provide isolation for processes, networking, and filesystems.
- User namespace remapping is a powerful but often overlooked security control.
- Cgroups prevent resource exhaustion and ensure fair workload distribution.
- Always define CPU, memory, and PID limits for production workloads.
- Continuously monitor container behavior to catch misconfigurations or abuse.
