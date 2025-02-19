resource "aws_security_group" "alb_sg" {
    name = "alb_sg"
    vpc_id = aws_vpc.highlvlwebarch.id
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_group_id = aws_security_group.instance_security_group.id
    source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = aws_security_group.instance_security_group.id
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "instance_security_group" {
    name = "instance_security_group"
    vpc_id = aws_vpc.highlvlwebarch.id
}

resource "aws_security_group" "rds_endpoint" {
    name = "rds_endpoint_sg"
    vpc_id = aws_vpc.highlvlwebarch.id
}

resource "aws_security_group_rule" "rds_endpoint_ingress_rule" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = aws_security_group.rds_endpoint.id
    source_security_group_id = aws_security_group.instance_security_group.id
}

resource "aws_security_group_rule" "rds_endpoint_egress_rule" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.rds_endpoint.id

}