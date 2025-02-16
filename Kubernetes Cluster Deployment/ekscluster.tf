module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.31"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = concat(module.vpc.public_subnets, module.vpc.private_subnets)


  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro", "t3.micro"]
  }

  eks_managed_node_groups = {
    example = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }
}