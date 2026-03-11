# Kubernetes Cluster Single AZ

This repo builds a single Kubernetes cluster in one AWS availability zone using:

- Terraform for AWS network + EC2 nodes
- Ansible for Kubernetes bootstrap and configuration

The cluster layout is fixed to 4 nodes:
- 1 control plane
- 3 workers

## Layout

- `infra/`: Terraform configuration
- `ansible/`: Ansible playbooks, roles, and inventory
- `scripts/`: bootstrap + helper scripts

Each folder also has its own README:
- `infra/README.md`
- `ansible/README.md`
- `scripts/README.md`

## Quick Start (New Machine)

1. Install prerequisites:
- `git`
- `python3` (3.11+ recommended)
- `terraform` (>= 1.14.3)
- AWS CLI (optional, but helpful)

2. Clone the repo and bootstrap tooling:

```bash
git clone <repo-url>
cd kubernetes-cluster-4nodes
./scripts/bootstrap.sh
```

3. Create `.env` and set required values:

```bash
cp .env.example .env
```

Edit `.env` and set:
- `AWS_REGION` (example: `eu-north-1`)
- `ANSIBLE_PRIVATE_KEY_FILE` (path to your EC2 private key)

4. Ensure AWS credentials are available in your shell (choose one):
- `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` (+ `AWS_SESSION_TOKEN` if needed)
- `aws sso login` with a configured profile
- Instance profile if running from EC2

5. Provision infrastructure:

```bash
cd infra
terraform init
terraform validate
terraform apply
```

6. Configure the cluster:

```bash
./scripts/run-ansible.sh
```

## Terraform Notes

Important variables in `infra/variables.tf`:

- `aws_region`
- `availability_zone_index`
- `control_plane_instance_type`
- `worker_instance_type`
- `key_name`
- `ssh_cidr`
- `root_volume_size`

Terraform creates tags used by Ansible inventory discovery:

- `Project = kubernetes-cluster-single-az`
- `Environment = single-cluster`
- `ManagedBy = terraform`
- `Cluster = single-az-k8s`
- `NodeType = control-plane` or `worker`
- `Name = k8s-control-plane-1`, `k8s-worker-1`, `k8s-worker-2`, `k8s-worker-3`

## Ansible Notes

Ansible uses the AWS EC2 dynamic inventory plugin:

- Inventory config: `ansible/inventory/aws_ec2.yml`
- Groups: `node_type_control_plane` and `node_type_worker`
- `ansible_host` is set to the EC2 public IP

The runner script:

- Loads `.env`
- Activates `.venv`
- Runs `playbooks/precheck.yml` then `playbooks/site.yml`

## Robust Usage Patterns

Re-run bootstrap if a new machine is missing Ansible or collections:

```bash
./scripts/bootstrap.sh
```

Re-run only the precheck to validate access:

```bash
cd ansible
ansible-playbook playbooks/precheck.yml
```

Re-run full configuration after infra changes:

```bash
./scripts/run-ansible.sh
```

## Troubleshooting

- Inventory fails: check AWS credentials and `AWS_REGION`.
- SSH unreachable: confirm `ANSIBLE_PRIVATE_KEY_FILE` and `ssh_cidr`.
- `/dev/shm` errors: handled automatically by `scripts/env.sh`.
- `kubeadm` errors: verify Kubernetes version in `ansible/group_vars/all.yml`.

## What Was Fixed And Why It Works Now

Earlier runs failed for multiple reasons. These fixes are now in the repo:

- Inventory host resolution: `ansible_host` now maps to `aws_public_ip_address`, so SSH uses the actual EC2 public IP instead of unresolved hostnames.
- Environment export: `.env` values are exported in `scripts/env.sh`, so `ANSIBLE_PRIVATE_KEY_FILE` and `AWS_REGION` reach Ansible.
- `/dev/shm` permission: when shared memory is not writable, `ANSIBLE_FORKS=1` is set to avoid multiprocessing errors.
- kubeadm config API: switched from `kubeadm.k8s.io/v1beta4` (experimental) to `v1beta3` so `kubeadm init` accepts the config.
- Kubernetes version: set to full semver (`1.30.0`) so kubeadm validates the version.
- Flannel install timing: added API health checks and waits before applying the CNI, and disabled validation for the manifest to avoid early API readiness errors.
- Prechecks expanded: playbook now verifies `AWS_REGION`, `ANSIBLE_PRIVATE_KEY_FILE`, AWS credentials, inventory host counts, and `ansible_host` presence.
- Deprecation warnings: disabled in Ansible config to reduce noise.
