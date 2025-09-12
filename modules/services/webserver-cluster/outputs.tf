output "lb_dns_name" {
  description = "This is the dns that you can use to access to the web"
  value = aws_lb.alb.dns_name
}


output "asg_name" {
  value = aws_autoscaling_group.asg.name
  description = "The name of asg"
}