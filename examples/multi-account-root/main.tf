
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

module "multi_account" {

    source = "../../modules/multi-account"
    providers = {
        aws.parent = aws.parent
        aws.child = aws.child
    }
}