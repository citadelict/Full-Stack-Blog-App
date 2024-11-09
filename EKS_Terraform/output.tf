output "cluster_id" {
  value = aws_eks_cluster.citatech.id
}

output "node_group_id" {
  value = aws_eks_node_group.citatech.id
}

output "vpc_id" {
  value = aws_vpc.citatech_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.citatech_subnet[*].id
}
