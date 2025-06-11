#!/bin/bash
# Wrapper around docker to log commands. Useful for auditing container actions.

echo "[audit] docker $@" >> docker-audit.log
exec docker "$@"
