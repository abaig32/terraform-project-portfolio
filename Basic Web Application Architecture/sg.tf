resource "aws_security_group" "instances" {
    name = "instances_security_group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.instances.id
}