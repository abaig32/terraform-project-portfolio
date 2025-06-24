terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.region
}


resource "aws_vpc" "newVPC" {
    cidr_block = "10.0.0.0/16"

    tags = {
      Name = "newVPC"
    }
} 

resource "aws_subnet" "PrivateSubnet" {
    vpc_id = aws_vpc.newVPC.id
    cidr_block = "10.0.1.0/24"

    tags = {
      Name = "PrivateSubnet"
    }
}

resource "aws_subnet" "PublicSubnet" {
    vpc_id = aws_vpc.newVPC.id
    cidr_block = "10.0.2.0/24"
    
    tags = {
      Name = "PublicSubnet"
    }
}

resource "aws_internet_gateway" "newGateway" {
    vpc_id = aws_vpc.newVPC.id

    tags = {
        Name = "newGateway"
    }
}

resource "aws_route_table" "PubRoute" {
    vpc_id = aws_vpc.newVPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.newGateway.id
    }
}

resource "aws_route_table_association" "PubAssociation" {
    subnet_id = aws_subnet.PublicSubnet.id
    route_table_id = aws_route_table.PubRoute.id
}