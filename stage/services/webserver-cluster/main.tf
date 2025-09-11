
provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "iac-s3-tarik"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "eu-west-3"
  }
}

data "terraform_remote_state" "db-state" {
  backend = "s3"
  config = {
    bucket = "iac-s3-tarik"
    key = "stage/services/data-store/mysql/terraform.tfstate"
    region = "eu-west-3"
  }
}

resource "aws_launch_template" "ec2" {

  image_id      = "ami-02d7ced41dff52ebc"
  instance_type = "t2.micro"

  user_data = base64encode(templatefile("./user-data.sh",{
    db_port = data.terraform_remote_state.db-state.outputs.port
    db_address = data.terraform_remote_state.db-state.outputs.address
    server_port = var.server_port
  }
    
  )
  )

  vpc_security_group_ids = [aws_security_group.sg.id]

  lifecycle {
    create_before_destroy = true
  }

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
    version = aws_launch_template.ec2.latest_version
  }
  lifecycle {
    create_before_destroy = true
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

