resource "aws_default_vpc" "default_vpc" {
 }

resource "aws_default_subnet" "default_subnet" {
    availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_2" {
    availability_zone = "us-east-1b"
}
