output "bucket_arn" {
  value = aws_s3_bucket.mybucket.arn
}

output "bucket_region" {
  value = aws_s3_bucket.mybucket.region
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.static_website.website_endpoint
}