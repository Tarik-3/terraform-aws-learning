
provider "aws" {
    region = "eu-west-3"
}

terraform {
    backend "s3" {
        bucket = "iac-s3-tarik"
        key = "stage/services/data-store/mysql/terraform.tfstate"
        region = "eu-west-3"
    }
}


resource "aws_db_instance" "mysql" {
    engine = "mysql"
    allocated_storage = 10
    db_name = "mydb"
    instance_class = "db.t3.micro"
    skip_final_snapshot = true

    password = var.db_password
    username = var.db_username
}