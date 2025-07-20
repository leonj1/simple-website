# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.s3_bucket_id}-${var.environment}-oac"
  description                       = "OAC for ${var.domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.domain_name}"
  default_root_object = var.index_document
  price_class         = var.price_class

  # Origin configuration for S3
  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_id                = "S3-${var.s3_bucket_id}"
    origin_path              = "/${var.s3_bucket_prefix}/${var.website_version}"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  # Default cache behavior
  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_bucket_id}"
    viewer_protocol_policy = var.use_ssl ? "redirect-to-https" : "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      headers      = []
      
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl

    # Security headers via response headers policy
    response_headers_policy_id = var.environment == "production" ? aws_cloudfront_response_headers_policy.security_headers[0].id : null
  }

  # Custom error responses
  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 300
    response_code         = 200
    response_page_path    = "/${var.index_document}"
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 300
    response_code         = 200
    response_page_path    = "/${var.index_document}"
  }

  # Aliases (alternate domain names)
  aliases = var.environment == "production" && var.domain_name != "" && var.acm_certificate_arn != "" ? [var.domain_name] : []

  # SSL/TLS certificate
  viewer_certificate {
    cloudfront_default_certificate = var.environment == "local" || var.acm_certificate_arn == ""
    acm_certificate_arn            = var.environment == "production" && var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.environment == "production" && var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version       = var.environment == "production" ? "TLSv1.2_2021" : null
  }

  # Geo restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Logging configuration (optional)
  # logging_config {
  #   include_cookies = false
  #   bucket          = "${var.s3_bucket_id}.s3.amazonaws.com"
  #   prefix          = "cloudfront-logs/"
  # }

  tags = merge(var.tags, {
    Name = "${var.domain_name}-distribution"
  })
}

# CloudFront Response Headers Policy for security headers
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  count   = var.environment == "production" ? 1 : 0
  name    = "${var.s3_bucket_id}-${var.environment}-security-headers"
  comment = "Security headers for ${var.domain_name}"

  security_headers_config {
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }

  custom_headers_config {
    items {
      header   = "X-Permitted-Cross-Domain-Policies"
      value    = "none"
      override = true
    }

    items {
      header   = "Permissions-Policy"
      value    = "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()"
      override = true
    }
  }
}