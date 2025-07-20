.PHONY: build clean install start zip docker-zip

PROJECT_NAME = dark-theme-landing
BUILD_DIR = build
DIST_FILE = $(PROJECT_NAME).zip
PROJECT_ZIP = $(PROJECT_NAME)-source.zip

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
	@docker build -f Dockerfile.zip -t project-zipper .
	@echo "Running zip in container..."
	@docker run --rm -v "$(PWD):/output" project-zipper
	@echo "Zip file created: $(PROJECT_ZIP)"