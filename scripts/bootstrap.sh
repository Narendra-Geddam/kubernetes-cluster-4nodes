#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    return 1
  fi
}

optional_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Warning: $cmd not found. Some tasks may fail without it." >&2
  fi
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

need_sudo() {
  if have_cmd sudo; then
    echo "sudo"
  else
    echo ""
  fi
}

install_packages() {
  local pkgs=("$@")
  local sudo_cmd
  sudo_cmd="$(need_sudo)"

  if have_cmd apt-get; then
    $sudo_cmd apt-get update -y
    $sudo_cmd apt-get install -y "${pkgs[@]}"
    return 0
  fi
  if have_cmd dnf; then
    $sudo_cmd dnf install -y "${pkgs[@]}"
    return 0
  fi
  if have_cmd yum; then
    $sudo_cmd yum install -y "${pkgs[@]}"
    return 0
  fi
  if have_cmd zypper; then
    $sudo_cmd zypper install -y "${pkgs[@]}"
    return 0
  fi
  if have_cmd pacman; then
    $sudo_cmd pacman -Sy --noconfirm "${pkgs[@]}"
    return 0
  fi

  echo "No supported package manager found (apt, dnf, yum, zypper, pacman)." >&2
  return 1
}

ensure_python() {
  if have_cmd python3; then
    return 0
  fi

  echo "python3 not found. Installing..." >&2
  if have_cmd apt-get; then
    install_packages python3 python3-venv python3-pip
    return 0
  fi
  if have_cmd dnf || have_cmd yum; then
    install_packages python3 python3-virtualenv python3-pip
    return 0
  fi
  if have_cmd zypper; then
    install_packages python3 python3-virtualenv python3-pip
    return 0
  fi
  if have_cmd pacman; then
    install_packages python python-pip
    return 0
  fi

  return 1
}

ensure_pip() {
  if python3 -m pip --version >/dev/null 2>&1; then
    return 0
  fi

  echo "pip not found. Installing..." >&2
  if have_cmd apt-get; then
    install_packages python3-pip
    return 0
  fi
  if have_cmd dnf || have_cmd yum; then
    install_packages python3-pip
    return 0
  fi
  if have_cmd zypper; then
    install_packages python3-pip
    return 0
  fi
  if have_cmd pacman; then
    install_packages python-pip
    return 0
  fi

  return 1
}

ensure_python
ensure_pip

optional_cmd terraform
optional_cmd aws

if [ ! -d "$ROOT_DIR/.venv" ]; then
  if ! python3 -m venv "$ROOT_DIR/.venv"; then
    echo "python3 venv module missing. Installing OS package for venv..." >&2
    if have_cmd apt-get; then
      install_packages python3-venv
    else
      install_packages python3-virtualenv
    fi
    python3 -m venv "$ROOT_DIR/.venv"
  fi
fi

# shellcheck disable=SC1091
source "$ROOT_DIR/.venv/bin/activate"

python3 -m pip install --upgrade pip
python3 -m pip install ansible-core boto3 botocore

mkdir -p "$ROOT_DIR/.ansible/tmp"
mkdir -p /tmp/ansible-local

ANSIBLE_CONFIG="$ROOT_DIR/ansible/ansible.cfg" \
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local \
ansible-galaxy collection install -r "$ROOT_DIR/ansible/requirements.yml"

if [ ! -f "$ROOT_DIR/.env" ] && [ -f "$ROOT_DIR/.env.example" ]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  echo "Created .env from .env.example. Update it with your values." >&2
fi

echo "Bootstrap complete."
