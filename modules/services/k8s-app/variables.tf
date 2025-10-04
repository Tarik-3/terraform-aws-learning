
variable "name" {
    description = "The name of our module"
    type = string
}

variable "container_port" {
    type = number
}
variable "environment_variables" {
    type = map(string)
    default = {}
}

variable "image" {
    description = "The image that we want to deploy"
    type = string
}

variable "replicas" {
    description = "The number of replicas we want to deploy"
    type = number
}