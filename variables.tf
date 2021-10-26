##################
# Terraform / AWS CONFIG
##################
variable "terraform_state_s3_bucket" {
  default = ""
}

variable "terraform_state_s3_key" {
  default = ""
}

variable "terraform_state_s3_dynamodb_table" {
  default = ""
}

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
# K8S CONFIG
#############
variable "kms_alias_name" {
  default = "sops_kms_key"
}

#############
# EKS
#############
variable "user_map" {
  default = []
}