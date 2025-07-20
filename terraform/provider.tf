provider "aws" {
  region = var.aws_region

  # Configure endpoints for LocalStack
  dynamic "endpoints" {
    for_each = var.environment == "local" ? [1] : []
    content {
      s3               = var.localstack_endpoint
      cloudfront       = var.localstack_endpoint
      route53          = var.localstack_endpoint
      route53domains   = var.localstack_endpoint
      acm              = var.localstack_endpoint
      sts              = var.localstack_endpoint
      iam              = var.localstack_endpoint
    }
  }

  # Skip credential validation for LocalStack
  skip_credentials_validation = var.environment == "local"
  skip_metadata_api_check     = var.environment == "local"
  skip_requesting_account_id  = var.environment == "local"

  # Use path-style addressing for S3 (required for LocalStack)
  s3_use_path_style = var.environment == "local"

  # Use dummy credentials for LocalStack
  access_key = var.environment == "local" ? "test" : null
  secret_key = var.environment == "local" ? "test" : null

  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
    })
  }
}

# Provider for ACM certificates in us-east-1 (required for CloudFront)
provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"

  # Configure endpoints for LocalStack
  dynamic "endpoints" {
    for_each = var.environment == "local" ? [1] : []
    content {
      acm = var.localstack_endpoint
      sts = var.localstack_endpoint
    }
  }

  # Skip credential validation for LocalStack
  skip_credentials_validation = var.environment == "local"
  skip_metadata_api_check     = var.environment == "local"
  skip_requesting_account_id  = var.environment == "local"

  # Use path-style addressing for S3 (required for LocalStack)
  s3_use_path_style = var.environment == "local"

  # Use dummy credentials for LocalStack
  access_key = var.environment == "local" ? "test" : null
  secret_key = var.environment == "local" ? "test" : null

  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
    })
  }
}