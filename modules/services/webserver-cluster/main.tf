


data "terraform_remote_state" "db-state" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key = var.db_remote_state_key
    region = "eu-west-3"
  }
}

resource "aws_launch_template" "ec2" {

  image_id      = "ami-02d7ced41dff52ebc"
  instance_type = "t2.micro"

  user_data = base64encode(templatefile("${path.module}/user-data.sh",{
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



locals {
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
  any_protocol = "-1"
  any_port = 0
  http_port = 80
  http_protocol = "HTTP"
}



resource "aws_security_group" "sg" {

  name = "iac-sg-${var.cluster_name}"

}

resource "aws_security_group_rule" "inbound_traffic" {
  type   = "ingress"

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.sg.id

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

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "iac-asg-${var.cluster_name}"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
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
  name = "iac-alb-${var.cluster_name}"
  load_balancer_type = "application"
  subnets = data.aws_subnets.sbn.ids

  security_groups = [aws_security_group.sg-lb.id]
}

resource "aws_security_group" "sg-lb" {
  name = "iac-lb-sg-${var.cluster_name}"
}

resource "aws_security_group_rule" "inbound_traffic_lb" {
  type   = "ingress"

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.sg-lb.id

}

resource "aws_security_group_rule" "outbound_traffic_lb" {
  type = "egress"

  from_port = local.any_port
  to_port = local.any_port
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
  
  security_group_id = aws_security_group.sg-lb.id

}

resource "aws_lb_listener" "lbl" {
  load_balancer_arn = aws_lb.alb.arn
  port = local.http_port
  protocol = local.http_protocol

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
    
  }
}

resource "aws_lb_target_group" "tg" {
  name = "iac-tg-${var.cluster_name}"
  port = var.server_port
  protocol = local.http_protocol
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

