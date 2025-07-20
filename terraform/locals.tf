locals {
  # S3 bucket configuration
  s3_origin_id = "S3-${var.s3_bucket_name}/${var.s3_bucket_prefix}"
  
  # CloudFront configuration
  cloudfront_origin_path = "/${var.s3_bucket_prefix}"
  
  # Domain configuration
  # For LocalStack, use the localstack.cloud subdomain
  # For production, use the actual domain
  website_domain = var.environment == "local" ? "${replace(var.domain_name, ".", "-")}.localhost.localstack.cloud" : var.domain_name
  
  # Extract root domain from subdomain (e.g., "website.joseserver.com" -> "joseserver.com")
  # This assumes a single subdomain level
  domain_parts = split(".", var.domain_name)
  root_domain = var.environment == "production" && length(local.domain_parts) > 2 ? join(".", slice(local.domain_parts, 1, length(local.domain_parts))) : var.domain_name
  
  # ACM configuration - only create in production with DNS resources
  create_acm_certificate = var.environment == "production" && var.use_ssl && var.create_dns_resources
  
  # S3 website endpoint
  s3_website_endpoint = var.environment == "local" ? "${var.s3_bucket_name}.s3-website.localhost.localstack.cloud" : "${var.s3_bucket_name}.s3-website-${var.aws_region}.amazonaws.com"
  
  # CloudFront aliases
  cloudfront_aliases = var.environment == "local" ? [] : [var.domain_name]
}