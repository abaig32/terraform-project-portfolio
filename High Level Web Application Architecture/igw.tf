resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.highlvlwebarch.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.PublicSubnet.id

  depends_on = [aws_internet_gateway.igw]

}