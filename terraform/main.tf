# S3 bucket module
module "s3" {
  source = "./modules/s3"

  create_bucket  = var.create_s3_bucket
  bucket_name    = var.s3_bucket_name
  bucket_prefix  = var.s3_bucket_prefix
  environment    = var.environment
  index_document = var.index_document
  error_document = var.error_document
  tags           = var.tags
}

# DNS and ACM module (only for certificate)
module "dns" {
  source = "./modules/dns"

  providers = {
    aws.acm_provider = aws.acm_provider
  }

  environment        = var.environment
  domain_name        = var.domain_name
  create_certificate = local.create_acm_certificate
  tags               = var.tags
}

# CloudFront distribution module
module "cloudfront" {
  source = "./modules/cloudfront"

  environment           = var.environment
  s3_bucket_id          = module.s3.bucket_id
  s3_bucket_domain_name = module.s3.bucket_domain_name
  s3_bucket_prefix      = var.s3_bucket_prefix
  domain_name           = var.domain_name
  acm_certificate_arn   = local.create_acm_certificate ? module.dns.certificate_arn : ""
  use_ssl               = var.use_ssl
  price_class           = var.cloudfront_price_class
  default_ttl           = var.cloudfront_default_ttl
  max_ttl               = var.cloudfront_max_ttl
  index_document        = var.index_document
  error_document        = var.error_document
  website_version       = var.website_version
  tags                  = var.tags

  depends_on = [
    module.dns
  ]
}

# Route53 A record for CloudFront distribution (production only with DNS resources)
resource "aws_route53_record" "website" {
  count   = var.environment == "production" && var.create_dns_resources ? 1 : 0
  zone_id = module.dns.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.cloudfront.distribution_domain_name
    zone_id                = module.cloudfront.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 A record for www subdomain (production only with DNS resources)
resource "aws_route53_record" "www" {
  count   = var.environment == "production" && var.create_dns_resources ? 1 : 0
  zone_id = module.dns.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.cloudfront.distribution_domain_name
    zone_id                = module.cloudfront.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}