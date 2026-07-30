terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "ecommerce-microservices-eks-bucket"
    key          = "dev/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ==================== VPC MODULE ====================
module "vpc" {
  source = "./modules/vpc" # ✅ CHANGED

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
  common_tags          = local.common_tags
}

# ==================== IAM MODULE ====================
module "iam" {
  source = "./modules/iam" # ✅ CHANGED

  project_name = var.project_name
  common_tags  = local.common_tags
}

# ==================== EKS MODULE ====================
module "eks" {
  source = "./modules/eks" # ✅ CHANGED

  cluster_name         = var.cluster_name
  cluster_version      = var.cluster_version
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  control_plane_sg_id  = module.vpc.eks_control_plane_security_group_id
  node_sg_id           = module.vpc.eks_nodes_security_group_id
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  eks_node_role_arn    = module.iam.eks_node_role_arn
  node_groups          = var.node_groups
  common_tags          = local.common_tags
}

# ==================== LOCAL VALUES ====================
locals {
  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Terraform   = "true"
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  )
}
