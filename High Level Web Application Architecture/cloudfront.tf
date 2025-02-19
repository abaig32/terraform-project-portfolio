resource "aws_cloudfront_distribution" "alb_distribution" {
    origin {
        domain_name = aws_lb.asg_lb.dns_name
        origin_id   = "ALB-Origin"

        custom_origin_config {
            http_port              = 80
            https_port             = 80
            origin_protocol_policy = "http-only"
            origin_ssl_protocols   = ["TLSv1.2"]
        }
    }

    enabled             = true
    is_ipv6_enabled     = true
    comment             = "CloudFront distribution with ALB as origin"
    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "ALB-Origin"

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "allow-all"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    depends_on = [aws_lb.asg_lb]
}
