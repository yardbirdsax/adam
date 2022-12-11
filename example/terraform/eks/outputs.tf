output "cluster_id" {
  value = module.eks_cluster.eks_cluster_id
}

output "role_arn" {
  value = module.irsa.service_account_role_arn
}