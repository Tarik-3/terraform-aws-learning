

output "address" {
    value = module.mysql_primary.address
    description = "db's address"
}

output "port" {
    description = "DB's port"
    value = module.mysql_primary.port
}