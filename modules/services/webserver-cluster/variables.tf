variable "server_port" {
  description = "This is the server's port of our server"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "This is a post fix for all the resource"
  type = string
}

variable "db_remote_state_key" {
  description = "This is the key of the remote state file"
  type = string
}

variable "bucket_name" {
  description = "This is the bucket's name"
  type = string
}

variable "min_size" {
  type = number
  default = 3
  description = "The min number of the instances"
}

variable "max_size" {
  type = number
  description = "Max number of the instances"
}

variable "custom_tags" {
  description = "Custom tags to set on the instance in ASG"
  type = map(string)
  default = {}
}

variable "enable_autoscaling" {
  description = "If is true, enable autoscaling"
  type = bool
}