output "eks_meta" {

    value = aws_eks_cluster.elliotteks
  
}

 output "eks_worker_node_metadata" {
   value = aws_eks_node_group.worker-node-group
 }