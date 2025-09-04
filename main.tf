provider "aws" {
    region = "eu-west-3"
}

resource "aws_instance" "ec2" {
    ami = "ami-02d7ced41dff52ebc"
    instance_type = "t2.micro"

    tags = {
        Name = "first_iac"
    }
}