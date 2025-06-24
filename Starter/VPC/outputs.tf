output "vpc_id" {
    value = aws_vpc.newVPC.id
}

output "vpc_cidr" {
    value = aws_vpc.newVPC.cidr_block
}