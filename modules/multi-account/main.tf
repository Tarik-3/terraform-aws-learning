
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            configuration_aliases = [aws.parent, aws.child]
        }
        
    }
}

data "aws_caller_identity" "parent" {
    provider = aws.parent
}

data "aws_caller_identity" "child" {
    provider = aws.child
}