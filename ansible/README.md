# Ansible Directory

This folder contains everything needed to configure the EC2 nodes into a Kubernetes cluster.
It uses the AWS EC2 dynamic inventory plugin to discover nodes based on tags created by Terraform.

## What This Does

- Connects to the EC2 instances created by Terraform.
- Installs Kubernetes prerequisites and container runtime on all nodes.
- Initializes the control plane and installs the CNI (Flannel).
- Joins worker nodes to the control plane.

## Inputs You Must Provide

1. AWS credentials available in your shell (one of these):
- `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` (and optionally `AWS_SESSION_TOKEN`)
- `aws sso login` with a configured profile
- Instance profile if you are running from an EC2 machine

2. Environment variables:
- `AWS_REGION` (must match your Terraform region)
- `ANSIBLE_PRIVATE_KEY_FILE` (path to the private key matching the EC2 key pair name)

If you use the root `.env` file with `./scripts/run-ansible.sh`, those values are loaded automatically.

## Inventory

Inventory is defined in `inventory/aws_ec2.yml` using the AWS dynamic inventory plugin.
Important behaviors:
- `ansible_host` uses the EC2 public IP address
- Hosts are grouped by the `NodeType` tag
- This inventory requires network access to the AWS API

## Common Commands

Run the precheck only:

```bash
cd ansible
ansible-playbook playbooks/precheck.yml
```

Run the full cluster setup:

```bash
cd ansible
ansible-playbook playbooks/site.yml
```

Or from the repo root after bootstrapping:

```bash
./scripts/run-ansible.sh
```

## Troubleshooting

- If inventory fails to load, verify AWS credentials and `AWS_REGION`.
- If SSH fails, verify `ANSIBLE_PRIVATE_KEY_FILE` and that security group allows SSH from your IP.
- If you see `/dev/shm` permission errors, the runner already reduces forks automatically.

