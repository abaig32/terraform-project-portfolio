resource "aws_lb" "asg_lb" {
    name = "asg-lb"
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws_subnet.PublicSubnet.id, aws_subnet.PublicSubnet2.id]
    internal = false
}

resource "aws_lb_target_group" "alb_target_group" {
    name = "alb-target-group"
    target_type = "instance"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.highlvlwebarch.id  
}



resource "aws_alb_listener" "alb_listener" {
    load_balancer_arn = aws_lb.asg_lb.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "Fixed Response"
        status_code = "200"
      }
    }
}

resource "aws_lb_listener_rule" "instances" {
    listener_arn = aws_alb_listener.alb_listener.arn
    priority = 100

    condition {
      path_pattern {
        values = ["*"]
      }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.alb_target_group.arn
    }
} 