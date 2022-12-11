terraform {
  required_version = "~>1.2"

  required_providers {
    aws = {
      # Pinned due to https://github.com/localstack/localstack/issues/7046
      version = "~>4.9.0"
      source  = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

data "aws_availability_zones" "az" {}

# tflint-ignore: terraform_module_version
module "label" {
  source = "cloudposse/label/null"
  # Cloud Posse recommends pinning every module to a specific version
  # version  = "x.x.x"

  namespace  = "crossplane-terraform-localstack"
  name       = "my"
  stage      = "dev"
  attributes = ["cluster"]
}

# tflint-ignore: terraform_module_version
module "vpc" {
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  ipv4_primary_cidr_block = "172.16.0.0/16"

  context = module.label.context
}

# tflint-ignore: terraform_module_version
module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  availability_zones   = data.aws_availability_zones.az.names
  vpc_id               = module.vpc.vpc_id
  igw_id               = [ module.vpc.igw_id ]

  nat_gateway_enabled  = true
  nat_instance_enabled = false

  context = module.label.context
}

# tflint-ignore: terraform_module_version
module "eks_cluster" {
  source = "cloudposse/eks-cluster/aws"

  region                       = var.region
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = concat(module.subnets.private_subnet_ids, module.subnets.public_subnet_ids)
  kubernetes_version           = var.kubernetes_version
  local_exec_interpreter       = var.local_exec_interpreter
  oidc_provider_enabled        = var.oidc_provider_enabled
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  cluster_log_retention_period = var.cluster_log_retention_period

  cluster_encryption_config_enabled                         = var.cluster_encryption_config_enabled
  cluster_encryption_config_kms_key_id                      = var.cluster_encryption_config_kms_key_id
  cluster_encryption_config_kms_key_enable_key_rotation     = var.cluster_encryption_config_kms_key_enable_key_rotation
  cluster_encryption_config_kms_key_deletion_window_in_days = var.cluster_encryption_config_kms_key_deletion_window_in_days
  cluster_encryption_config_kms_key_policy                  = var.cluster_encryption_config_kms_key_policy
  cluster_encryption_config_resources                       = var.cluster_encryption_config_resources

  addons = var.addons

  # We need to create a new Security Group only if the EKS cluster is used with unmanaged worker nodes.
  # EKS creates a managed Security Group for the cluster automatically, places the control plane and managed nodes into the security group,
  # and allows all communications between the control plane and the managed worker nodes
  # (EKS applies it to ENIs that are attached to EKS Control Plane master nodes and to any managed workloads).
  # If only Managed Node Groups are used, we don't need to create a separate Security Group;
  # otherwise we place the cluster in two SGs - one that is created by EKS, the other one that the module creates.
  # See https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html for more details.
  create_security_group = false

  # This is to test `allowed_security_group_ids` and `allowed_cidr_blocks`
  # In a real cluster, these should be some other (existing) Security Groups and CIDR blocks to allow access to the cluster
  # allowed_security_group_ids = [module.vpc.vpc_default_security_group_id]
  allowed_cidr_blocks        = [module.vpc.vpc_cidr_block]

  # For manual testing. In particular, set `false` if local configuration/state
  # has a cluster but the cluster was deleted by nightly cleanup, in order for
  # `terraform destroy` to succeed.
  apply_config_map_aws_auth = var.apply_config_map_aws_auth

  context = module.label.context
}

module "eks_node_group" {
  source  = "cloudposse/eks-node-group/aws"
  version = "2.4.0"

  subnet_ids        = module.subnets.private_subnet_ids
  cluster_name      = module.eks_cluster.eks_cluster_id
  instance_types    = var.instance_types
  desired_size      = var.desired_size
  min_size          = var.min_size
  max_size          = var.max_size
  kubernetes_labels = var.kubernetes_labels

  # Prevent the node groups from being created before the Kubernetes aws-auth ConfigMap
  module_depends_on = module.eks_cluster.kubernetes_config_map_id

  context = module.label.context
}

data "aws_iam_policy_document" "irsa" {
  statement {
    effect = "Allow"
    actions = [
      "iam:*"
    ]
    resources = [ "*" ]
  }
}

module "irsa" {
  source = "cloudposse/eks-iam-role/aws"
  version = "1.1.0"

  eks_cluster_oidc_issuer_url = module.eks_cluster.eks_cluster_identity_oidc_issuer
  service_account_name = "provider-terraform-*"
  service_account_namespace = "crossplane-system"
  aws_iam_policy_document = [ data.aws_iam_policy_document.irsa.json ]

}
