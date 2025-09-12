
provider "aws" {
    region = "eu-west-3"
}

terraform {
    backend "s3" {
        bucket = "iac-s3-tarik"
        key = "prod/data-stores/terraform.tfstate"
        region = "eu-west-3"

    }
}

resource "aws_db_instance" "mysql" {
    db_name = "proddb"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    password = var.prod_db_pass
    username = var.prod_db_username
}