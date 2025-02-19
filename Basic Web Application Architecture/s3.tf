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
