
provider "aws" {
    region = "eu-west-1"
    alias = "parent"
}

provider "aws" {
    region = "eu-west-2"
    alias = "child"

    assume_role {
        role_arn = "arn:aws:iam::302009675076:role/OrganizationAccountAccessRole"
    }
}

data "aws_caller_identity" "parent" {
    provider = aws.parent
}

data "aws_caller_identity" "child" {
    provider = aws.child
}