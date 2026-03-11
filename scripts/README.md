# Scripts

This folder provides a beginner-friendly workflow for preparing a new machine and running Ansible.

## bootstrap.sh

Purpose:
- Creates a local Python virtual environment in `.venv`
- Installs `ansible-core`, `boto3`, and `botocore`
- Installs Ansible collections from `ansible/requirements.yml`
- Creates local temp directories for Ansible

It will attempt to install `python3` and `pip` using common Linux package managers:
`apt`, `dnf`, `yum`, `zypper`, or `pacman` (requires sudo).

Run:

```bash
./scripts/bootstrap.sh
```

## env.sh

Purpose:
- Loads `.env` from the repo root
- Exports `ANSIBLE_CONFIG` and `ANSIBLE_LOCAL_TEMP`
- Ensures temp dirs exist
- Reduces forks if `/dev/shm` is not writable

You usually do not run this directly; it is used by the runner.

## run-ansible.sh

Purpose:
- Loads env vars from `.env`
- Activates the local Python virtualenv
- Runs the Ansible precheck and the full site playbook

Run:

```bash
./scripts/run-ansible.sh
```
