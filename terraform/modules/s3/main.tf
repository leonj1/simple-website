# Data source for existing bucket (production)
data "aws_s3_bucket" "existing" {
  count  = var.create_bucket ? 0 : 1
  bucket = var.bucket_name
}

# Create S3 bucket (LocalStack only)
resource "aws_s3_bucket" "website" {
  count  = var.create_bucket ? 1 : 0
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name = var.bucket_name
  })
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "website" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.website[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block (allowing public access for static website)
resource "aws_s3_bucket_public_access_block" "website" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.website[0].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "website" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.website[0].id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# S3 bucket policy for CloudFront and public access
resource "aws_s3_bucket_policy" "website" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.website[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website[0].arn}/${var.bucket_prefix}/*"
      },
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website[0].arn}/${var.bucket_prefix}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# S3 bucket CORS configuration
resource "aws_s3_bucket_cors_configuration" "website" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.website[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Create the folder structure
resource "aws_s3_object" "folder" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.website[0].id
  key    = "${var.bucket_prefix}/"
  
  tags = merge(var.tags, {
    Description = "Folder for ${var.bucket_prefix} website files"
  })
}