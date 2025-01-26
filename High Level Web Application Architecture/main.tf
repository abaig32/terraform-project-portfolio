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

resource "aws_vpc" "highlvlwebarch" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "PublicSubnet" {
    vpc_id = aws_vpc.highlvlwebarch.id
    cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "PrivateSubnet" {
    vpc_id = aws_vpc.highlvlwebarch.id
    cidr_block = "10.0.2.0/24"
}

resource "aws_instance" "server" {
    count = 2

    ami = var.ec2_instance_ami
    instance_type = var.ec2_instance_type
    security_groups = [aws_security_group.instance_security_group.id]
    subnet_id = aws_subnet.PrivateSubnet.id

}

resource "aws_security_group" "instance_security_group" {
    name = "instance_security_group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_group_id = aws_security_group.instance_security_group.id
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_s3_bucket" "instances_bucket" {
    bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-sse" {
    bucket = aws_s3_bucket.instances_bucket.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
    bucket = aws_s3_bucket.instances_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_db_instance" "rdswebapp_instance" {
    allocated_storage = 20
    storage_type = "standard"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = var.db_username
    password = var.db_password
    skip_final_snapshot = true
}