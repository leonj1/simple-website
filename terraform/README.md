# Terraform Infrastructure for Simple Website

This Terraform configuration manages the infrastructure for hosting a static website with S3, CloudFront, Route53, and ACM.

## Architecture

- **S3 Bucket**: Stores the static website files
- **CloudFront**: CDN for global content delivery
- **Route53**: DNS management
- **ACM**: SSL/TLS certificates (production only)

## Key Features

- **Environment-specific configuration**: Separate configurations for LocalStack (local) and AWS (production)
- **Conditional S3 bucket creation**: Creates bucket only in LocalStack, uses existing bucket in production
- **SSL/TLS support**: Automatic certificate provisioning in production
- **Modular design**: Reusable modules for S3, CloudFront, and DNS

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured (for production)
- LocalStack running (for local development)
- Domain name with Route53 hosted zone (for production)

## Directory Structure

```
terraform/
├── main.tf                 # Root module
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── provider.tf            # Provider configuration
├── versions.tf            # Version constraints
├── locals.tf              # Local values
├── modules/               # Reusable modules
│   ├── s3/               # S3 bucket module
│   ├── cloudfront/       # CloudFront module
│   └── dns/              # Route53 & ACM module
└── environments/          # Environment configs
    ├── local.tfvars      # LocalStack config
    └── prod.tfvars       # Production config
```

## Usage

### LocalStack Development

1. Start LocalStack:
   ```bash
   docker-compose up -d
   ```

2. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

3. Plan the deployment:
   ```bash
   terraform plan -var-file=environments/local.tfvars
   ```

4. Apply the configuration:
   ```bash
   terraform apply -var-file=environments/local.tfvars
   ```

5. Upload your website files to S3:
   ```bash
   aws --endpoint-url=http://localhost:4566 s3 cp ../dark-theme-landing-v1.0.0.zip s3://area51dapidi/simple-website/
   ```

### Production Deployment

1. Update `environments/prod.tfvars` with your domain name

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the deployment:
   ```bash
   terraform plan -var-file=environments/prod.tfvars
   ```

4. Apply the configuration:
   ```bash
   terraform apply -var-file=environments/prod.tfvars
   ```

## Environment Variables

### local.tfvars
- `create_s3_bucket = true` - Creates S3 bucket in LocalStack
- `use_ssl = false` - No SSL for local development
- `domain_name = "simple-website.localhost"` - Local domain

### prod.tfvars
- `create_s3_bucket = false` - Uses existing S3 bucket
- `use_ssl = true` - Enables SSL/TLS
- `domain_name = "simple-website.example.com"` - Your actual domain

## Outputs

- `s3_bucket_name` - Name of the S3 bucket
- `cloudfront_distribution_id` - CloudFront distribution ID
- `cloudfront_domain_name` - CloudFront domain name
- `website_url` - Full website URL
- `acm_certificate_arn` - ACM certificate ARN (production only)

## Destroying Infrastructure

LocalStack:
```bash
terraform destroy -var-file=environments/local.tfvars
```

Production:
```bash
terraform destroy -var-file=environments/prod.tfvars
```

## Important Notes

1. **S3 Bucket**: In production, the S3 bucket `area51dapidi` must already exist
2. **Domain**: Update the domain name in `prod.tfvars` to your actual domain
3. **Route53**: Ensure you have a Route53 hosted zone for your domain
4. **Costs**: CloudFront and Route53 incur AWS charges in production
5. **LocalStack Pro**: Some features may require LocalStack Pro license

## Troubleshooting

### LocalStack Issues
- Ensure LocalStack is running: `docker-compose ps`
- Check LocalStack health: `curl http://localhost:4566/_localstack/health`
- Verify AWS CLI configuration for LocalStack

### Production Issues
- Verify AWS credentials: `aws sts get-caller-identity`
- Check Route53 hosted zone exists
- Ensure S3 bucket exists and is accessible
- ACM certificate validation can take up to 30 minutes

## Security Considerations

- S3 bucket has public read access for static website hosting
- CloudFront Origin Access Control (OAC) restricts S3 access
- SSL/TLS enforced in production
- Consider enabling CloudFront security headers
- Review and adjust S3 bucket policies as needed