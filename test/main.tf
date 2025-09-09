provider "aws" {

}

resource "aws_instance" "ec2" {
    ami = "ami-02d7ced41dff52ebc"
    instance_type = "t2.micro"


}

terraform {
    backend "s3" {
        bucket = "my-s3-tarik"
        key = "workspace/instance/terraform.tfstate"
        encrypt = true
        region = "eu-west-3"

    }
}