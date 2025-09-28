

provider "aws" {
    region = "eu-west-3"
}

resource "aws_instance" "ci" {
    ami = "ami-02d7ced41dff52ebc"
    instance_type = "t2.micro"

    iam_instance_profile = aws_iam_instance_profile.profile.name

    key_name = aws_key_pair.ssh.key_name

    vpc_security_group_ids = [aws_security_group.sg.id]
}

resource "aws_key_pair" "ssh" {
    key_name = "my_ssh_key"
    public_key = file(var.public_ssh_path)
}

resource "aws_security_group" "sg" {
    name = "access_ssh"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_iam_policy_document" "doc" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "instance" {
    assume_role_policy = data.aws_iam_policy_document.doc.json
}

data "aws_iam_policy_document" "ec2-admin" {
    statement {
        effect = "Allow"
        actions = ["ec2:*"]
        resources = ["*"]
    }
}

resource "aws_iam_role_policy" "exp" {
    role = aws_iam_role.instance.id
    policy = data.aws_iam_policy_document.ec2-admin.json
}

resource "aws_iam_instance_profile" "profile" {
    role = aws_iam_role.instance.name
}