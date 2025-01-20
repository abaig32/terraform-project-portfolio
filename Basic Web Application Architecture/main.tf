 terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
 }


provider "aws" {
    region = "us-east-1"
 }


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

resource "aws_s3_bucket" "instancebucket" {
    bucket = "bucketforinstances"
    force_destroy = true
 }

resource "aws_s3_bucket_versioning" "instancebucket_versioning" {
    bucket = aws_s3_bucket.instancebucket.id

    versioning_configuration {
        status = "Enabled"
    }
 }

resource "aws_s3_bucket_server_side_encryption_configuration" "instancebucket_sse" {
    bucket = aws_s3_bucket.instancebucket.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_default_vpc" "default_vpc" {
 }

resource "aws_default_subnet" "default_subnet" {
    availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_2" {
    availability_zone = "us-east-1b"
}

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

resource "aws_route53_zone" "primary" {
    name = "example.com"
}

resource "aws_route53_record" "root" {
    zone_id = aws_route53_zone.primary.zone_id
    name = "example.com"
    type = "A"

    alias {
        name = aws_lb.load_balancer.dns_name
        zone_id = aws_lb.load_balancer.zone_id
        evaluate_target_health = true
    }
}

resource "aws_db_instance" "myinstance" {
    allocated_storage = 20
    storage_type = "standard"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = "foo"
    password = "foobarbaz"
    skip_final_snapshot = true
}