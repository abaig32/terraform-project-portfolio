terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}


resource "aws_instance" "ApacheInstance" {
    instance_type = "t2.micro"
    ami = "ami-020cba7c55df1f615"
    associate_public_ip_address = true
    security_groups = [var.security_group]

    tags = {
      Name = "ApacheInstance"
    }
}