output "availability_zone" {
  description = "Availability zone hosting the cluster"
  value       = aws_subnet.public.availability_zone
}

output "vpc_id" {
  description = "VPC ID for the single-cluster deployment"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet used by all cluster nodes"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security group attached to all cluster nodes"
  value       = aws_security_group.cluster.id
}

output "cluster_nodes" {
  description = "Node inventory information for Ansible and verification"
  value = {
    for node_name, instance in aws_instance.cluster_nodes : node_name => {
      id         = instance.id
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      node_type  = instance.tags["NodeType"]
      name       = instance.tags["Name"]
    }
  }
}

output "control_plane_public_ip" {
  description = "Public IP of the control plane node"
  value       = aws_instance.cluster_nodes["control-plane-1"].public_ip
}
