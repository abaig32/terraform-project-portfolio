resource "aws_security_group" "worker_nodes_sg" {
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "worker_nodes_ingress" {
    type = "ingress"
    from_port = 0
    protocol = "-1"
    to_port = 0
    security_group_id = aws_security_group.worker_nodes_sg.id
    cidr_blocks = ["10.0.0.0/8"]
}

resource "aws_security_group_rule" "worker_nodes_egress" {
    type = "egress"
    from_port = 0
    protocol = "-1"
    to_port = 0
    security_group_id = aws_security_group.worker_nodes_sg.id
    cidr_blocks = ["0.0.0.0/0"]
}
