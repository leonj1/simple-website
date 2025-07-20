# LocalStack Pro Setup

This project includes a Docker Compose configuration for running LocalStack Pro locally.

## Prerequisites

1. Docker and Docker Compose installed
2. LocalStack Pro license token (get one at https://app.localstack.cloud)

## Setup

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and add your LocalStack Pro license token:
   ```
   LOCALSTACK_AUTH_TOKEN=your-actual-token-here
   ```

3. Create necessary directories:
   ```bash
   mkdir -p localstack-data localstack-init
   ```

## Usage

### Start LocalStack Pro

```bash
docker-compose up -d
```

### Check if LocalStack is running

```bash
curl http://localhost:4566/_localstack/health
```

### View logs

```bash
docker-compose logs -f localstack
```

### Stop LocalStack

```bash
docker-compose down
```

### Stop and remove all data

```bash
docker-compose down -v
rm -rf localstack-data
```

## AWS CLI Configuration

Configure AWS CLI to use LocalStack:

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export AWS_ENDPOINT_URL=http://localhost:4566
```

Or create a profile in `~/.aws/config`:

```
[profile localstack]
region = us-east-1
output = json
endpoint_url = http://localhost:4566
```

And in `~/.aws/credentials`:

```
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

Then use: `aws --profile localstack s3 ls`

## Available Services

The following AWS services are enabled by default:
- S3
- Lambda
- DynamoDB
- SQS
- SNS
- CloudFormation
- IAM
- SSM (Systems Manager)
- Secrets Manager

To add more services, edit the `SERVICES` variable in your `.env` file.

## Initialization Scripts

Place any initialization scripts in the `localstack-init` directory. These will be executed when LocalStack starts up.

Example: `localstack-init/ready.d/01-create-buckets.sh`
```bash
#!/bin/bash
awslocal s3 mb s3://my-test-bucket
```

## Troubleshooting

1. **Container won't start**: Check if port 4566 is already in use
2. **License error**: Verify your LOCALSTACK_AUTH_TOKEN is correct
3. **Services not available**: Check logs and ensure the service is included in SERVICES env var
4. **Permission errors**: Ensure Docker socket is accessible

## Additional Resources

- [LocalStack Documentation](https://docs.localstack.cloud)
- [LocalStack Pro Features](https://localstack.cloud/pricing/)
- [AWS CLI with LocalStack](https://docs.localstack.cloud/user-guide/integrations/aws-cli/)