output "port" {
    description = "The port of the db:"
    value = aws_db_instance.mysql.port
}

output "address" {
    description = "The address of the db:"
    value = aws_db_instance.mysql.address
}