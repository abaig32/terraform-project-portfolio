module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = flatten([module.vpc.public_subnets, module.vpc.private_subnets])

  iam_role_arn = aws_iam_role.eks_cluster_role.arn

  eks_managed_node_groups = {
    example = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 2

      node_role_arn = aws_iam_role.eks_node_role.arn

    }
  }
}
