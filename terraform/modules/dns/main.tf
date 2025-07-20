# Configure provider requirement
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
      configuration_aliases = [aws.acm_provider]
    }
  }
}

# Data source for existing Route53 hosted zone
data "aws_route53_zone" "main" {
  count        = var.environment == "production" ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

# ACM Certificate (production only)
resource "aws_acm_certificate" "website" {
  provider = aws.acm_provider
  count    = var.create_certificate ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.domain_name}-certificate"
  })
}

# ACM Certificate validation DNS records
resource "aws_route53_record" "certificate_validation" {
  for_each = var.create_certificate ? {
    for dvo in aws_acm_certificate.website[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main[0].zone_id
}

# ACM Certificate validation
resource "aws_acm_certificate_validation" "website" {
  provider = aws.acm_provider
  count    = var.create_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.website[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]

  timeouts {
    create = "30m"
  }
}

