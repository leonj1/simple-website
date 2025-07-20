output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = var.s3_bucket_name
}

output "s3_bucket_website_endpoint" {
  description = "S3 bucket website endpoint"
  value       = local.s3_website_endpoint
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "website_url" {
  description = "Website URL"
  value       = var.use_ssl ? "https://${local.website_domain}" : "http://${local.website_domain}"
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = module.dns.zone_id
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN (if created)"
  value       = local.create_acm_certificate ? module.dns.certificate_arn : null
}

output "website_dns_name" {
  description = "Website DNS record name"
  value       = var.environment == "production" ? aws_route53_record.website[0].name : ""
}

output "website_dns_fqdn" {
  description = "Website DNS record FQDN"
  value       = var.environment == "production" ? aws_route53_record.website[0].fqdn : ""
}