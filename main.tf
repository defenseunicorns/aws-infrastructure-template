###################
# Terraform config
###################
terraform {
  backend "s3" {
    bucket         = "infra-aws-tf-state"
    key            = "infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "bb-infra-terraform-state-lock"
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
  target_key_id = aws_kms_key.kms_sops.id
}

resource "aws_kms_grant" "kms_permissions" {
  name              = "kms-grant-sops"
  key_id            = aws_kms_key.kms_sops.key_id
  grantee_principal = module.eks_cluster.eks.cluster_iam_role_arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}
