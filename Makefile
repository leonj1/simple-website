.PHONY: build clean install start zip docker-zip tf-build tf-init tf-plan tf-apply tf-destroy tf-shell tf-output tf-prod-build tf-prod-init tf-prod-plan tf-prod-apply tf-prod-destroy

PROJECT_NAME = dark-theme-landing
BUILD_DIR = build
DIST_FILE = $(PROJECT_NAME).zip
VERSION ?= latest
PROJECT_ZIP = $(PROJECT_NAME)-$(VERSION).zip

install:
	npm install

start:
	npm start

build:
	npm run build
	cd $(BUILD_DIR) && zip -r ../$(DIST_FILE) .

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(DIST_FILE)
	rm -rf node_modules
	rm -f $(PROJECT_ZIP)

zip:
	@echo "Creating source zip file: $(PROJECT_ZIP)"
	@zip -r $(PROJECT_ZIP) . \
		-x "node_modules/*" \
		-x "$(BUILD_DIR)/*" \
		-x "*.zip" \
		-x ".git/*" \
		-x ".gitignore" \
		-x "*.log" \
		-x ".DS_Store"

docker-zip:
	@echo "Building Docker image for zip..."
	@docker build -f Dockerfile.zip -t project-zipper --build-arg VERSION=$(VERSION) .
	@echo "Running zip in container with version $(VERSION)..."
	@docker run --rm -v "$(PWD):/output" -e VERSION=$(VERSION) project-zipper
	@echo "Zip file created: $(PROJECT_ZIP)"

localstack-up:
	docker compose up -d

localstack-down: tf-destroy
	@echo "Destroying Terraform resources (if any)..."
	-@$(MAKE) tf-destroy 2>/dev/null || true
	@echo "Stopping LocalStack..."
	docker compose down -v

localstack-logs:
	docker compose logs

# Terraform configuration
TF_DIR = terraform
TF_IMAGE = terraform-local
TF_VARS = -var-file=environments/local.tfvars
LOCALSTACK_NETWORK = localstack-network

# Production Terraform configuration
TF_PROD_VARS = -var-file=environments/prod.tfvars
TF_PROD_IMAGE = terraform-prod

# Terraform targets
tf-build:
	@echo "Building Terraform Docker image..."
	@docker build -f Dockerfile.terraform -t $(TF_IMAGE) .

tf-init: tf-build
	@echo "Initializing Terraform (workspace: local)..."
	@docker run --rm \
		--network $(LOCALSTACK_NETWORK) \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
		$(TF_IMAGE) init
	@docker run --rm \
		--network $(LOCALSTACK_NETWORK) \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
		$(TF_IMAGE) workspace new local || true
	@docker run --rm \
		--network $(LOCALSTACK_NETWORK) \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
		$(TF_IMAGE) workspace select local

tf-plan: tf-init
	@echo "Planning Terraform changes..."
	@docker run --rm \
		--network $(LOCALSTACK_NETWORK) \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
		$(TF_IMAGE) plan $(TF_VARS)

tf-apply: tf-init tf-build
	@echo "Applying Terraform changes..."
	@docker run --rm \
		--network $(LOCALSTACK_NETWORK) \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
		$(TF_IMAGE) apply $(TF_VARS) -auto-approve

tf-destroy: tf-build
	@echo "Destroying Terraform resources..."
	@if [ -f "$(TF_DIR)/terraform.tfstate" ]; then \
		docker run --rm \
			--network $(LOCALSTACK_NETWORK) \
			-v "$(PWD)/$(TF_DIR):/workspace" \
			-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
			$(TF_IMAGE) destroy $(TF_VARS) -auto-approve; \
	else \
		echo "No terraform state found, skipping destroy"; \
	fi

tf-shell: tf-build
	@echo "Opening Terraform shell..."
	@docker run --rm -it \
		--network $(LOCALSTACK_NETWORK) \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
		--entrypoint /bin/bash \
		$(TF_IMAGE)

tf-output: tf-build
	@echo "Showing Terraform outputs..."
	@docker run --rm \
		--network $(LOCALSTACK_NETWORK) \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) \
		$(TF_IMAGE) output -json

# Production Terraform targets
tf-prod-build:
	@echo "Building Terraform Docker image for production..."
	@docker build -f Dockerfile.terraform.prod -t $(TF_PROD_IMAGE) .

tf-prod-init: tf-prod-build
	@echo "Initializing Terraform for production (workspace: prod)..."
	@docker run --rm \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
		-e AWS_REGION=$(AWS_REGION) \
		$(TF_PROD_IMAGE) init
	@docker run --rm \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
		-e AWS_REGION=$(AWS_REGION) \
		$(TF_PROD_IMAGE) workspace new prod || true
	@docker run --rm \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
		-e AWS_REGION=$(AWS_REGION) \
		$(TF_PROD_IMAGE) workspace select prod

tf-prod-plan: tf-prod-init
	@echo "Planning Terraform changes for production..."
	@docker run --rm \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
		-e AWS_REGION=$(AWS_REGION) \
		$(TF_PROD_IMAGE) plan $(TF_PROD_VARS)

tf-prod-apply: tf-prod-init
	@echo "Applying Terraform changes to production..."
	@echo "WARNING: This will make changes to production AWS resources!"
	@docker run --rm \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
		-e AWS_REGION=$(AWS_REGION) \
		$(TF_PROD_IMAGE) apply $(TF_PROD_VARS) -auto-approve

tf-prod-destroy: tf-prod-build
	@echo "WARNING: This will DESTROY production AWS resources!"
	@echo "Press Ctrl+C to cancel..."
	@sleep 5
	@docker run --rm \
		-v "$(PWD)/$(TF_DIR):/workspace" \
		-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
		-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
		-e AWS_REGION=$(AWS_REGION) \
		$(TF_PROD_IMAGE) destroy $(TF_PROD_VARS) -auto-approve
