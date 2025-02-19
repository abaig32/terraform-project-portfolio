resource "aws_vpc_endpoint_route_table_association" "s3_private" {
    vpc_endpoint_id = aws_vpc_endpoint.s3.id
    route_table_id = aws_route_table.privateroute.id
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.highlvlwebarch.id
    service_name = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Gateway"
    auto_accept = true
}

resource "aws_vpc_endpoint" "rds" {
    vpc_id = aws_vpc.highlvlwebarch.id
    service_name = "com.amazonaws.us-east-1.rds"
    vpc_endpoint_type = "Interface"
    subnet_ids = [aws_subnet.PrivateSubnet.id]
    security_group_ids = [aws_security_group.rds_endpoint.id]
    auto_accept = true 
}