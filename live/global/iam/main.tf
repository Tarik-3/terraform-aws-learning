provider "aws" {
    region = "eu-west-3"
}

terraform {
    backend "s3" {
        bucket = "iac-s3-tarik"
        key = "global/iam/terraform.tfstate"
        region = "eu-west-3"
    }
}

module "users" {
    source = "../../../modules/landing-zone/iam-user"
    list_users = var.users_names
}