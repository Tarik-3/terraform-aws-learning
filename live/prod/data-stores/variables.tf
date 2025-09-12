variable "prod_db_pass" {
    description = "The db's passwd "
    type = string
    sensitive = true
}

variable "prod_db_username" {
    description = "The db's username"
    type = string
}
