output "instance_ip" {
    value = aws_instance.ApacheInstance.public_ip
}

output "instance_az" {
    value = aws_instance.ApacheInstance.availability_zone
}