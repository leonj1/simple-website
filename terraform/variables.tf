variable "environment" {
  description = "Environment name (local or production)"
  type        = string
  validation {
    condition     = contains(["local", "production"], var.environment)
    error_message = "Environment must be either 'local' or 'production'."
  }
}

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket (true for LocalStack, false for production)"
  type        = bool
  default     = false
}

variable "create_dns_resources" {
  description = "Whether to create Route53 and ACM resources (set to false if you don't have a domain yet)"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "area51dapidi"
}

variable "s3_bucket_prefix" {
  description = "Prefix/folder in S3 bucket for the website files"
  type        = string
  default     = "simple-website"
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "use_ssl" {
  description = "Whether to use SSL/TLS (false for LocalStack)"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "simple-website"
    ManagedBy   = "terraform"
  }
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "cloudfront_default_ttl" {
  description = "Default TTL for CloudFront cache"
  type        = number
  default     = 3600
}

variable "cloudfront_max_ttl" {
  description = "Maximum TTL for CloudFront cache"
  type        = number
  default     = 86400
}

variable "index_document" {
  description = "Index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document for the website"
  type        = string
  default     = "error.html"
}

variable "website_version" {
  description = "Version of the website to deploy (e.g., v1.2.3)"
  type        = string
  default     = "latest"
}