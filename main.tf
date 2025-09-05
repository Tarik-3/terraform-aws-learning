
provider "aws" {
 
}

resource "aws_launch_template" "ec2" {
  name_prefix = "web-"
  image_id         = "ami-02d7ced41dff52ebc"
  instance_type = "t2.micro"

  user_data = base64encode(<<-EOF
                #!/bin/bash
                mkdir -p /var/www
                echo "Hello, Tarik is here again" > /var/www/index.html
                cd /var/www
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
  )
  vpc_security_group_ids = [aws_security_group.sg.id]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg" {
  name = "my_sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "vpc" {
    default = true
}

data "aws_subnets" "subnets" {

    filter {
        name = "vpc-id"
        values = [data.aws_vpc.vpc.id]
    }
}

resource "aws_autoscaling_group" "asg" {
    launch_template {
        id = aws_launch_template.ec2.id
    } 

    min_size = 3
    max_size = 10
    vpc_zone_identifier = data.aws_subnets.subnets.ids

    tag {
        key = "Name"
        value = "terr-asg-test"
        propagate_at_launch = true
    }
}


