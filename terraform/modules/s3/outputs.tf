output "bucket_id" {
  description = "The name of the bucket"
  value       = var.create_bucket ? aws_s3_bucket.website[0].id : data.aws_s3_bucket.existing[0].id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = var.create_bucket ? aws_s3_bucket.website[0].arn : data.aws_s3_bucket.existing[0].arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = var.create_bucket ? aws_s3_bucket.website[0].bucket_domain_name : data.aws_s3_bucket.existing[0].bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = var.create_bucket ? aws_s3_bucket.website[0].bucket_regional_domain_name : data.aws_s3_bucket.existing[0].bucket_regional_domain_name
}

output "website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website"
  value       = var.create_bucket ? aws_s3_bucket_website_configuration.website[0].website_endpoint : ""
}

output "website_domain" {
  description = "The domain of the website endpoint"
  value       = var.create_bucket ? aws_s3_bucket_website_configuration.website[0].website_domain : ""
}