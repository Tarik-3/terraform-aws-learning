
output "server_ip" {
    value = aws_instance.ci.public_ip
}