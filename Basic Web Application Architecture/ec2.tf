resource "aws_instance" "instance1" {
    ami = "ami-0df8c184d5f6ae949"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
 }

resource "aws_instance" "instance2" {
    ami = "ami-0df8c184d5f6ae949"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instances.name]
 }

