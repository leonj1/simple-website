output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = try(data.aws_route53_zone.main[0].zone_id, "")
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = var.create_certificate ? aws_acm_certificate.website[0].arn : ""
}

output "certificate_status" {
  description = "ACM certificate status"
  value       = var.create_certificate ? aws_acm_certificate.website[0].status : ""
}

output "certificate_validation_options" {
  description = "ACM certificate validation options"
  value       = var.create_certificate ? aws_acm_certificate.website[0].domain_validation_options : []
}

