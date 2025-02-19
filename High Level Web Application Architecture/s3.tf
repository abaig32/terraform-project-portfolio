resource "aws_s3_bucket" "instances_bucket_2025" {
    bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-sse" {
    bucket = aws_s3_bucket.instances_bucket_2025.id

    rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
    bucket = aws_s3_bucket.instances_bucket_2025.id    
    versioning_configuration {
      status = "Enabled"
    }
}
