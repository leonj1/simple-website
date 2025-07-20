variable "environment" {
  description = "Environment name"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 bucket ID"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  type        = string
}

variable "s3_bucket_prefix" {
  description = "S3 bucket prefix for website files"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
  default     = ""
}

variable "use_ssl" {
  description = "Whether to use SSL"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "default_ttl" {
  description = "Default TTL in seconds"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL in seconds"
  type        = number
  default     = 86400
}

variable "index_document" {
  description = "Index document"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Error document"
  type        = string
  default     = "error.html"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}