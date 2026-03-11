# Kubernetes Cluster Single AZ

This project provisions a single Kubernetes cluster in one AWS availability zone with four EC2 nodes:

- 1 control plane
- 3 workers

Terraform creates the AWS network and instances. Ansible configures Kubernetes from another machine by using the AWS dynamic inventory plugin.

## Layout

- `infra/`: Terraform for the VPC, subnet, security group, and EC2 nodes
- `ansible/`: Portable Ansible configuration for kubeadm bootstrap

## Terraform

```bash
cd infra
terraform init
terraform validate
terraform apply
```

Important inputs in `infra/variables.tf`:

- `control_plane_instance_type`
- `worker_instance_type`
- `key_name`
- `ssh_cidr`

## Ansible

Run Ansible from another machine with AWS credentials and the EC2 private key available:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
export AWS_REGION=eu-north-1
export ANSIBLE_PRIVATE_KEY_FILE=/path/to/private-key.pem
ansible-playbook playbooks/precheck.yml
ansible-playbook playbooks/site.yml
```

The inventory groups hosts by EC2 tags:

- `node_type_control_plane`
- `node_type_worker`

## Tags Created For Ansible Discovery

- `Project = kubernetes-cluster-single-az`
- `Environment = single-cluster`
- `ManagedBy = terraform`
- `Cluster = single-az-k8s`
- `NodeType = control-plane` or `worker`
- `Name = k8s-control-plane-1`, `k8s-worker-1`, `k8s-worker-2`, `k8s-worker-3`

# kubernetes-cluster-4nodes
