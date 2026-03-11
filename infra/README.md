# Terraform Infrastructure

This folder provisions the AWS infrastructure for a single-AZ Kubernetes cluster:

- VPC, subnet, route table, internet gateway
- Security group for the cluster nodes
- 1 control plane EC2 instance
- 3 worker EC2 instances

## Prerequisites

- Terraform `>= 1.14.3`
- AWS credentials in your environment

## Key Variables

Defined in `variables.tf`:

- `aws_region`: AWS region (default `eu-north-1`)
- `availability_zone_index`: which AZ to use (default `0`)
- `key_name`: EC2 key pair name (must exist in AWS)
- `ssh_cidr`: CIDR allowed to SSH into nodes
- `control_plane_instance_type`, `worker_instance_type`

## Common Commands

From the repo root:

```bash
./scripts/bootstrap.sh
```

Then:

```bash
cd infra
terraform init
terraform validate
terraform apply
```

## Outputs

`outputs.tf` includes:

- `cluster_nodes` map with public/private IPs
- `control_plane_public_ip`
- `vpc_id`, `public_subnet_id`, `security_group_id`

