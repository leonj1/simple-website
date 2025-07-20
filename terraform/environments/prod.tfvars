# Production environment configuration
environment          = "production"
create_s3_bucket     = false
create_dns_resources = true  # Enable Route53 and ACM resources
s3_bucket_name       = "area51dapidi"
s3_bucket_prefix     = "simple-website"
domain_name          = "website.joseserver.com"  # Subdomain for the website
use_ssl              = true
aws_region           = "us-east-1"

# CloudFront settings for production
cloudfront_price_class = "PriceClass_100"  # Use PriceClass_All for global distribution
cloudfront_default_ttl = 3600
cloudfront_max_ttl     = 86400

# Website files
index_document = "index.html"
error_document = "error.html"
website_version = "v1.0.0"  # Update this to deploy a specific version

# Tags
tags = {
  Environment = "production"
  Project     = "simple-website"
  ManagedBy   = "terraform"
  Purpose     = "static-website-hosting"
}
