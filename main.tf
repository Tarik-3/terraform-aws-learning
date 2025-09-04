provider "aws" {
    region = "eu-west-3"
}

resource "aws_instance" "ec2" {
    ami = "ami-02d7ced41dff52ebc"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg.id]

    user_data = <<-EOF
              #!/bin/bash
              mkdir -p /var/www
              echo "Hello, Tarik is here again" > /var/www/index.html
              cd /var/www
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

    user_data_replace_on_change = true

    tags = {
        Name = "first_iac"
    }
}

resource "aws_security_group" "sg" {
    name = "my_sg"
    
    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
}