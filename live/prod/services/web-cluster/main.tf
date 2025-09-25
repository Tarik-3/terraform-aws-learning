
provider "aws" {
    region = "eu-west-3"

    default_tags {
        tags = {
            Owner = "Tarik"
            ManagedBy = "Terraform"
        }
    }
}

terraform {
    backend "s3" {
        bucket = "iac-s3-tarik"
        key = "prod/services/webserver-cluster/terraform.tfstate"
        region = "eu-west-3"
    }
    
}

module "webserver-cluster" {

    cluster_name = "prod"
    min_size = 3
    max_size = 10 
    enable_autoscaling = true
    server_text = "Tarik Tarik"


    
    source = "../../../../modules/services/webserver-cluster"

    db_remote_state_key =  "prod/data-stores/terraform.tfstate"
    bucket_name = "iac-s3-tarik"

    custom_tags = {
        Owner= "team-tarik"
        ManagedBy = "terraform"
    }

}


