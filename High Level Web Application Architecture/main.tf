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

resource "aws_vpc" "highlvlwebarch" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "PublicSubnet" {
    vpc_id = aws_vpc.highlvlwebarch.id
    cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "PrivateSubnet" {
    vpc_id = aws_vpc.highlvlwebarch.id
    cidr_block = "10.0.2.0/24"
}

resource "aws_lb" "asg_lb" {
    name = "asg-lb"
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws_subnet.PublicSubnet.id]
}

resource "aws_lb_target_group" "alb_target_group" {
    name = "alb-target-group"
    target_type = "alb"
    port = 80
    protocol = "TCP"
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

resource "aws_autoscaling_attachment" "asg_attachment" {
    autoscaling_group_name = aws_autoscaling_group.asg.id
    lb_target_group_arn = aws_lb_target_group.alb_target_group.arn
}

resource "aws_security_group" "alb_sg" {
    name = "alb_sg"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.alb_sg.id
}

resource "aws_wafv2_ip_set" "blacklist_ip_set" {
    name = "blacklist-ip-set"
    scope = "CLOUDFRONT"
    ip_address_version = "IPV4"
    addresses = var.alb_ip_sets
}

resource "aws_wafv2_web_acl" "asg_web_acl" {
    name = "asg-web-acl"
    scope = "REGIONAL"
    default_action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name = var.metric_name
      sampled_requests_enabled = true
    }

    rule {
        name = "DomesticRateBasedRule"
        priority = 1

        action {
            block{}
        }

        statement {
          rate_based_statement {
            limit = 2000
            aggregate_key_type = "IP"

            scope_down_statement {
              geo_match_statement {
                country_codes = ["US"]
              }
            }
          }
        }

        visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "DomesticRateBasedRuleLogs"
          sampled_requests_enabled = true
        }
    }

    rule {
        name = "IPBlacklist"
        priority = 2

        action {
            block{}
        }

        statement {
          or_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.blacklist_ip_set.arn
              }
            }
          }
        }

        visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "IPBlacklistLogs"
          sampled_requests_enabled = true
        }
    }

}

resource "aws_wafv2_web_acl_logging_configuration" "webacl_logging" {
    log_destination_configs = [aws_s3_bucket.logging_bucket.arn]
    resource_arn = aws_wafv2_web_acl.asg_web_acl.arn
}

resource "aws_wafv2_web_acl_association" "waf_alb_association" {
    resource_arn = aws_lb.asg_lb.arn
    web_acl_arn = aws_wafv2_web_acl.asg_web_acl.arn
}

resource "aws_launch_template" "asg_ec2_launchtemp" {
    name_prefix = "asg_ec2_launchtemp"
    image_id = var.ec2_instance_ami
    instance_type = var.ec2_instance_type

    network_interfaces {
      security_groups = [aws_security_group.instance_security_group.id]
    }
}

resource "aws_cloudfront_distribution" "alb_distribution" {
    origin {
        domain_name = aws_lb.asg_lb.dns_name
        origin_id = "ALB-Origin"
    }

    enabled = true
    is_ipv6_enabled = true
    comment = "CloudFront distribution with ALB as origin"
    default_root_object = "index.html"

    aliases = ["mysite.example.com", "yoursite.example.com"]
    default_cache_behavior {
        allowed_methods = ["GET", "HEAD", "OPTIONS"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "ALB-Origin"

        forwarded_values {
          query_string = false
          cookies {
            forward = "none"
          }
        }

        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource "aws_route53_zone" "cfd_zone" {
    name = "example.com"
}

resource "aws_route53_record" "cloudfront_alias" {
    zone_id = aws_route53_zone.cfd_zone.id
    name = "www.example.com"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.alb_distribution.domain_name
        zone_id = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
        evaluate_target_health = false
    }
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

resource "aws_security_group" "instance_security_group" {
    name = "instance_security_group"
    vpc_id = aws_vpc.highlvlwebarch.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_group_id = aws_security_group.instance_security_group.id
    cidr_blocks = ["0.0.0.0/0"]
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
    cidr_blocks = ["10.0.0.0/16"]
    security_group_id = aws_security_group.rds_endpoint.id
}

resource "aws_security_group_rule" "rds_endpoint_egress_rule" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.rds_endpoint.id
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.highlvlwebarch.id
}

resource "aws_route_table" "privateroute" {
    vpc_id = aws_vpc.highlvlwebarch.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_vpc_endpoint.s3.id
    }
}

resource "aws_route_table" "publicroute" {
    vpc_id = aws_vpc.highlvlwebarch.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "publicsub_route" {
    subnet_id = aws_subnet.PublicSubnet.id
    route_table_id = aws_route_table.publicroute.id
}

resource "aws_vpc_endpoint_route_table_association" "s3_private" {
    vpc_endpoint_id = aws_vpc_endpoint.s3.id
    route_table_id = aws_route_table.privateroute.id
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.highlvlwebarch.id
    service_name = "com.amazonaws.us-east-1.s3"
    vpc_endpoint_type = "Gateway"
    auto_accept = true
}

resource "aws_vpc_endpoint" "rds" {
    vpc_id = aws_vpc.highlvlwebarch.id
    service_name = "com.amazonaws.us-east-1.rds"
    vpc_endpoint_type = "Interface"
    subnet_ids = [aws_subnet.PrivateSubnet.id]
    security_group_ids = [aws_security_group.rds_endpoint.id]
    auto_accept = true 
}


resource "aws_s3_bucket" "instances_bucket" {
    bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-sse" {
    bucket = aws_s3_bucket.instances_bucket.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
    bucket = aws_s3_bucket.instances_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_s3_bucket" "logging_bucket" {
    bucket = "logging_bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket_s3-sse" {
    bucket = aws_s3_bucket.instances_bucket.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_versioning" "logging_bucket_versioning" {
    bucket = aws_s3_bucket.instances_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_db_instance" "rdswebapp_instance" {
    allocated_storage = 20
    storage_type = "standard"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = var.db_username
    password = var.db_password
    skip_final_snapshot = true
}