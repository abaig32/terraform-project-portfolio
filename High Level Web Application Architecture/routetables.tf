resource "aws_route_table" "privateroute" {
    vpc_id = aws_vpc.highlvlwebarch.id
    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat.id
    }

    depends_on = [aws_vpc_endpoint.s3]
}


resource "aws_route_table" "publicroute" {
    vpc_id = aws_vpc.highlvlwebarch.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "publicsub_route" {
    subnet_id = aws_subnet.PublicSubnet.id
    route_table_id = aws_route_table.publicroute.id
}

resource "aws_route_table_association" "privatesub_route" {
  subnet_id = aws_subnet.PrivateSubnet.id
  route_table_id = aws_route_table.privateroute.id
}