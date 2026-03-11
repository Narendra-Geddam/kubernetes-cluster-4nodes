variable "aws_region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region"
}

variable "availability_zone_index" {
  type        = number
  default     = 0
  description = "Zero-based AZ index to place the single-AZ cluster into"
}

variable "cluster_name" {
  type        = string
  default     = "single-az-k8s"
  description = "Cluster identifier used in tags and kubeadm"
}

variable "project_tag" {
  type        = string
  default     = "kubernetes-cluster-single-az"
  description = "Project tag used for Terraform and Ansible discovery"
}

variable "environment_tag" {
  type        = string
  default     = "single-cluster"
  description = "Environment tag used for Terraform and Ansible discovery"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.42.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.42.1.0/24"
  description = "CIDR block for the single public subnet"
}

variable "pod_network_cidr" {
  type        = string
  default     = "10.244.0.0/16"
  description = "Pod CIDR passed into kubeadm and the CNI"
}

variable "service_cidr" {
  type        = string
  default     = "10.96.0.0/12"
  description = "Cluster service CIDR passed into kubeadm"
}

variable "control_plane_instance_type" {
  type        = string
  default     = "c7i-flex.large"
  description = "Instance type for the control plane node"
}

variable "worker_instance_type" {
  type        = string
  default     = "t3.small"
  description = "Instance type for the worker nodes"
}

variable "ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR allowed to SSH into nodes"
}

variable "key_name" {
  type        = string
  default     = "Ansible"
  description = "EC2 key pair name used for SSH access"
}

variable "root_volume_size" {
  type        = number
  default     = 30
  description = "Root EBS volume size in GiB for all nodes"
}
