#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
  set +a
fi

export ANSIBLE_CONFIG="$ROOT_DIR/ansible/ansible.cfg"
export ANSIBLE_LOCAL_TEMP="/tmp/ansible-local"

mkdir -p "$ROOT_DIR/.ansible/tmp" /tmp/ansible-local

SHM_TEST="/dev/shm/ansible_shm_test_$$"
if ! ( : > "$SHM_TEST" ) 2>/dev/null; then
  export ANSIBLE_FORKS=1
else
  rm -f "$SHM_TEST"
fi
