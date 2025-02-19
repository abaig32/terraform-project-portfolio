resource "aws_vpc" "highlvlwebarch" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "PublicSubnet" {
    vpc_id = aws_vpc.highlvlwebarch.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id = aws_vpc.highlvlwebarch.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
}


resource "aws_subnet" "PrivateSubnet" {
    vpc_id = aws_vpc.highlvlwebarch.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
}