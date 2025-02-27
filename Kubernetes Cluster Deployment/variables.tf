#Variables


variable "region" {
    type = string
    default = "us-east-1"
}

variable "vpc_name" {
    type = string
    default = "todolist-vpc"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "kubernetes_version" {
    type = string
    default = "1.32"
}