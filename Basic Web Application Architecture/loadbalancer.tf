resource "aws_lb" "load_balancer" {
    name = "web-app-lb"
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = [
        aws_default_subnet.default_subnet.id,
        aws_default_subnet.default_subnet_2.id 
        ]
}

resource "aws_security_group" "alb" {
    name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.alb.id
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
    type = "egress"
    security_group_id = aws_security_group.alb.id
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.load_balancer.arn
    port = 80
    protocol = "HTTP"

    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code = 404
      }
    }
}

resource "aws_lb_listener_rule" "instances" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
      path_pattern {
        values = ["*"]
      }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.instances.arn
    }
} 


resource "aws_lb_target_group" "instances" {
    name = "instance-target-group"
    port = 8080
    protocol = "HTTP"
    vpc_id = aws_default_vpc.default_vpc.id

    health_check {
      path = "/"
      protocol = "HTTP"
      matcher = "200"
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group_attachment" "instance1" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id = aws_instance.instance1.id
    port = 8080
}

resource "aws_lb_target_group_attachment" "instance2" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id = aws_instance.instance2.id
    port = 8080
}