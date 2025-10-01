
output "arn" {
    value = aws_db_instance.mysql.arn
}

output "address" {
    value = aws_db_instance.mysql.address
    description = "db's address"
}

output "port" {
    description = "DB's port"
    value = aws_db_instance.mysql.port
}