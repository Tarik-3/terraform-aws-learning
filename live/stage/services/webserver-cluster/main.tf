provider "aws" {
  region = "eu-west-3"
}

module "ec2-cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name = "web-stage"
  db_remote_state_key = "stage/services/data-store/mysql/terraform.tfstate"
  bucket_name = "iac-s3-tarik"
  enable_autoscaling = false
}