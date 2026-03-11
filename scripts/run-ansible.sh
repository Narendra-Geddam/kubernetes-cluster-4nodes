#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/env.sh"

if [ -d "$ROOT_DIR/.venv" ]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.venv/bin/activate"
fi

if [ -z "${ANSIBLE_PRIVATE_KEY_FILE:-}" ]; then
  echo "ANSIBLE_PRIVATE_KEY_FILE is not set. Update .env and retry." >&2
  exit 1
fi

cd "$ROOT_DIR/ansible"
ansible-playbook playbooks/precheck.yml
ansible-playbook playbooks/site.yml
