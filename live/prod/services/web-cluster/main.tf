
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
    
    source = "../../../../modules/services/webserver-cluster"

    db_remote_state_key =  "prod/data-stores/terraform.tfstate"
    bucket_name = "iac-s3-tarik"

    custom_tags = {
        Owner= "team-tarik"
        ManagedBy = "terraform"
    }

}



resource "aws_autoscaling_schedule" "working_time" {
    
    scheduled_action_name = "scale-out-during-morning"
    min_size = 3
    max_size = 10
    desired_capacity = 10
    recurrence = "0 9 * * *"

    autoscaling_group_name = module.webserver-cluster.asg_name
}


resource "aws_autoscaling_schedule" "breaking_time" {
    
    scheduled_action_name = "scale-in-during-night"
    min_size = 3
    max_size = 10
    desired_capacity = 3
    recurrence = "0 17 * * *"

    autoscaling_group_name = module.webserver-cluster.asg_name
}