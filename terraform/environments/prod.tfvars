# Production environment configuration
environment          = "production"
create_s3_bucket     = false
s3_bucket_name       = "area51dapidi"
s3_bucket_prefix     = "simple-website"
domain_name          = "simple-website.example.com"  # Replace with your actual domain
use_ssl              = true
aws_region           = "us-east-1"

# CloudFront settings for production
cloudfront_price_class = "PriceClass_100"  # Use PriceClass_All for global distribution
cloudfront_default_ttl = 3600
cloudfront_max_ttl     = 86400

# Website files
index_document = "index.html"
error_document = "error.html"

# Tags
tags = {
  Environment = "production"
  Project     = "simple-website"
  ManagedBy   = "terraform"
  Purpose     = "static-website-hosting"
}