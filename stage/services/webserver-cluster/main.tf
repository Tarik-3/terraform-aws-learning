
provider "aws" {

}



resource "aws_launch_template" "ec2" {

  image_id      = "ami-02d7ced41dff52ebc"
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

}

resource "aws_security_group" "sg" {

  name = "iac-sg"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

}

resource "aws_autoscaling_group" "asg" {

  launch_template {
    id = aws_launch_template.ec2.id
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "iac-asg"
    propagate_at_launch = true
  }

  vpc_zone_identifier = data.aws_subnets.sbn.ids
}

data "aws_subnets" "sbn" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_vpc" "vpc" {
  default = true
}

resource "aws_lb" "alb" {
  name = "iac-alb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.sbn.ids

  security_groups = [aws_security_group.sg-lb.id]
}

resource "aws_security_group" "sg-lb" {
  name = "iac-lb-sg"
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "lbl" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
    
  }
}

resource "aws_lb_target_group" "tg" {
  name = "iac-tg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2

  }
}

resource "aws_lb_listener_rule" "lr" {

  listener_arn = aws_lb_listener.lbl.arn
  priority = 100

  condition  {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

