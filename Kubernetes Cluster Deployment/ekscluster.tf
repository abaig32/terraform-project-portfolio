module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    instance_types = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.worker_nodes_sg.id]
  }


  eks_managed_node_groups = {
    one = {

      min_size     = 1
      max_size     = 2
      desired_size = 1

    }
  }
}
