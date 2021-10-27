##################
# AWS CONFIG
##################
variable "aws_profile" {
  default = ""
}

variable "aws_region" {
  default = ""
}

#############
# K8S CONFIG
#############
variable "cluster_name" {
  default = ""
}

variable "kubernetes_version" {
  default = "1.19"
}

#############
# KMS CONFIG
#############
variable "kms_alias_name" {
  default = "alias/sops_kms_key"
}

#############
# EKS
#############
variable "user_map" {}
