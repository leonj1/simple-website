# LocalStack environment configuration
environment          = "local"
create_s3_bucket     = true
s3_bucket_name       = "area51dapidi"
s3_bucket_prefix     = "simple-website"
domain_name          = "simple-website.localhost"
use_ssl              = false
aws_region           = "us-east-1"
localstack_endpoint  = "http://localstack:4566"

# CloudFront settings for local
cloudfront_price_class = "PriceClass_100"
cloudfront_default_ttl = 3600
cloudfront_max_ttl     = 86400

# Website files
index_document = "index.html"
error_document = "error.html"
website_version = "latest"

# Tags
tags = {
  Environment = "local"
  Project     = "simple-website"
  ManagedBy   = "terraform"
  Purpose     = "localstack-testing"
}