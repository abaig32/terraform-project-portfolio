terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.region
}


resource "aws_s3_bucket" "mybucket" {
    bucket = var.bucket_name

    tags = {
      Name = "My Bucket"
    }
}

resource "aws_s3_bucket_policy" "allow_read_access" {
    bucket = aws_s3_bucket.mybucket.id
    policy = data.aws_iam_policy_document.allow_read_access.json
}

data "aws_iam_policy_document" "allow_read_access" {
    statement {
      principals {
        type = "*"
        identifiers = [ "*" ]
      }

      actions = [
        "s3:GetObject"
      ]

      resources = [ 
        aws_s3_bucket.mybucket.arn,
        "${aws_s3_bucket.mybucket.arn}/*"
       ]
    }
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key = "index.html"
  content = file("C:/Users/abaig/OneDrive/Desktop/Terraform Project Portfolio/Starter/Webpages/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key = "error.html"
  content = file("C:/Users/abaig/OneDrive/Desktop/Terraform Project Portfolio/Starter/Webpages/error.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_public_access_block" "websitebucket" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "static_website" {
    bucket = aws_s3_bucket.mybucket.id

    index_document {
      suffix = "index.html"
    }

    error_document {
      key = "error.html"
    }
}

