###################
# Terraform config
###################
terraform {
  backend "s3" {
    bucket         = "hypergiant-aws-tf-state"
    key            = "leapfrog-test/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "lf-hg-tf-states-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#################
# Provider defs
#################

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks_cluster.cluster_name,
      "--profile",
      var.aws_profile
    ]
  }
}

#############
# Deploy EKS
#############

module "eks_cluster" {
  source             = "github.com/defenseunicorns/aws-eks"
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  map_users          = var.user_map
}

#################
# KMS for SOPS
#################

resource "aws_kms_key" "kms_sops" {
  description             = "key for big bang sops"
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 30
  enable_key_rotation     = false
}

resource "aws_kms_alias" "kms_alias" {
  name          = var.kms_alias_name
  target_key_id = aws_kms_key.default.id
}

resource "aws_kms_grant" "kms_permissions" {
  name              = "kms-grant-sops"
  key_id            = aws_kms_key.kms_sops.key_id
  grantee_principal = module.eks_cluster.eks.eks_node_group_role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}

######################
# Deploy Private Zone
######################
resource "aws_route53_zone" "private" {
  name = var.private_dns_zone_name

  vpc {
    vpc_id = module.eks_cluster.vpc_id
  }

  comment = var.cluster_name
}
