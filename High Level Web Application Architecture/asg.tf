resource "aws_autoscaling_attachment" "asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.asg.id
    lb_target_group_arn = aws_lb_target_group.alb_target_group.arn
}

resource "aws_autoscaling_group" "asg" {
    vpc_zone_identifier = [aws_subnet.PrivateSubnet.id]
    desired_capacity = 2
    max_size = 3
    min_size = 1
    health_check_type = "ELB"
    health_check_grace_period = 300

    launch_template {
      id = aws_launch_template.asg_ec2_launchtemp.id
      version = "$Latest"
    }
}

resource "aws_launch_template" "asg_ec2_launchtemp" {
    name_prefix = "asg_ec2_launchtemp"
    image_id = var.ec2_instance_ami
    instance_type = var.ec2_instance_type

    network_interfaces {
      security_groups = [aws_security_group.instance_security_group.id]
    }
}