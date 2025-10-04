
variable "name" {
    type = string
}

variable "min_size" {
    type = number
}

variable "max_size" {
    type = number
}

variable "desired_size" {
    type = number
}

variable "instances_types" {
    type  = list(string)
    description = "The types of instances that we wil have in our cluster"
}