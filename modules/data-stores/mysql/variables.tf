
variable "db_password" {
    sensitive = true
    default = null
}

variable "db_username" {
    type  = string
    default = null
}

variable "db_name" {
    type = string
    default = null
}

variable "allow_replicas" {
    default = null
}

variable "replicate_source_db" {
    default = null
}