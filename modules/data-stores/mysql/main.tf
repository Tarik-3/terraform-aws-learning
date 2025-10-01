terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}
resource "aws_db_instance" "mysql" {

    
    allocated_storage = 10
    instance_class = "db.t3.micro"

    db_name = var.db_name
    skip_final_snapshot = true

   

    backup_retention_period = var.allow_replicas
    replicate_source_db = var.replicate_source_db

    engine = var.replicate_source_db == null ? "mysql" : null
    password = var.replicate_source_db == null ? var.db_password : null
    username = var.replicate_source_db == null ? var.db_username : null
}