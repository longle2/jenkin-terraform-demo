terraform {
  backend "s3" {
    bucket         = "dragon-terraform-state-s3-backend"
    key            = "terraform-jenkins"
    region         = "ap-southeast-1"
    encrypt        = true
    role_arn       = "arn:aws:iam::035296596762:role/Dragon-Terraform-StateS3BackendRole"
    dynamodb_table = "dragon-terraform-state-s3-backend"
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "static" {
  bucket        = "dragon-terraform-static-2"
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.static.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "static" {
  depends_on = [
	aws_s3_bucket_public_access_block.example,
	aws_s3_bucket_ownership_controls.example,
  ]
  bucket = aws_s3_bucket.static.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.static.json
}

resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.static.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "static" {
  statement {
    sid = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static.arn}/*"]

    principals {
      type = "*"
      identifiers = ["*"]
    }
  }
}

locals {
  tags = {
    hehe = "tada"
  }
  mime_types = {
    html  = "text/html"
    css   = "text/css"
    ttf   = "font/ttf"
    woff  = "font/woff"
    woff2 = "font/woff2"
    js    = "application/javascript"
    map   = "application/javascript"
    json  = "application/json"
    jpg   = "image/jpeg"
    png   = "image/png"
    svg   = "image/svg+xml"
    eot   = "application/vnd.ms-fontobject"
  }
}


output "name" {
  value= path.module
}