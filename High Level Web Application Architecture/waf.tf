resource "aws_wafv2_ip_set" "blacklist_ip_set" {
    name = "blacklist-ip-set"
    scope = "REGIONAL"
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
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.blacklist_ip_set.arn
              }
        }

        visibility_config {
          cloudwatch_metrics_enabled = true
          metric_name = "IPBlacklistLogs"
          sampled_requests_enabled = true
        }
    }

}

resource "aws_wafv2_web_acl_association" "waf_alb_association" {
    resource_arn = aws_lb.asg_lb.arn
    web_acl_arn = aws_wafv2_web_acl.asg_web_acl.arn
}