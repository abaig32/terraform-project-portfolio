# resource "aws_route53_zone" "cfd_zone" {
#     name = "example.com"
# }

# resource "aws_route53_record" "cloudfront_alias" {
#     zone_id = aws_route53_zone.cfd_zone.id
#     name = "www.example.com"
#     type = "A"

#     alias {
#         name = aws_cloudfront_distribution.alb_distribution.domain_name
#         zone_id = aws_cloudfront_distribution.alb_distribution.hosted_zone_id
#         evaluate_target_health = false
#     }
# }