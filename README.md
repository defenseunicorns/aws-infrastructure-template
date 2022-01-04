## AWS Infrastructure Template
This template can be used to set up an AWS eks cluster using terraform

Before running terraform you must manually create the s3 bucket and dynamodb table where the terraform state is going to be stored. For the dynamodb partition key use LockID (String) - see instructions below.


How to use this template repo:


1. Log into the AWS Console and create an S3 bucket.
2. Name the bucket. It may be helpful to append your bucket name with `tf-state`.
3. Create the bucket using the default options, unless otherwise needed.
4. Go into `main.tf` and update the S3 bucket name with the name selected in step 2 (line 6). 
5. Create a DynamoDB table in the AWS console. Modify the the name in `main.tf`, `bb-infra-terraform-state-lock` so that it is not a duplicate (ex. - `xyz-bb-infra-terraform-state-lock`). The name must be unique for tables created in the same region. For the partition key, make the name `LockID`.
6. Create a `terraform.tfvars` file within this directory.
7. Include the user map information in the `terraform.tfvars` for the accounts which will be accessing the cluster. An example is included below:
```
user_map = [
    {
      userarn  = "arn:aws:iam::950698127059:user/test"
      username = "test"
      groups   = ["system:masters"]
    },
```
8. Provide an alias for the KMS key to be used in the `terraform.tfvars` file (ex. - `kms_alias_name = "alias/xyz_sops_kms_key"`)

9. Run `terraform init`, `terraform plan`, `terraform apply`.

10. A kubeconfig file will be included at the root of this directory. Use this kubeconfig file to connect to the cluster.